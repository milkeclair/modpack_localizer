require "dotenv"
require "translation_api"
require_relative "../util/help"
require_relative "../util/error"
require_relative "reader"
require_relative "writer"

module ModpackLocalizer
  module JAR
    # .jarの翻訳を実行するクラス
    class Performer
      Dotenv.load

      MAX_RETRIES = 8
      BASE_DELAY = 5
      MAX_SLEEP = 256

      # locale_codeを指定する場合、countryの指定は不要
      #
      # @param [Boolean] output_logs APIのログを出力するか
      # @param [Array<String>] except_words 翻訳しない単語
      # @param [String] language 言語
      # @param [String] country 国
      # @param [String] locale_code ロケールコード (例: "ja_jp")
      # @param [Boolean] display_help ヘルプを表示するか
      # @return [ModpackLocalizer::JAR::Performer]
      def initialize(
        output_logs: true, except_words: [], language: "Japanese",
        country: "Japan", locale_code: nil, display_help: true
      )
        TranslationAPI.configure do |config|
          config.output_logs   = output_logs
          config.language      = language.downcase
          config.except_words  = except_words
          config.provider      = ENV["PROVIDER"]&.to_sym || :openai
          config.custom_prompt = "Never translate property access. Example: obj.property.child"
        end

        @language, @country_name, @locale_code = language, country, locale_code
        @reader, @writer, @progress_bar, @loggable, @tierdown = nil

        ModpackLocalizer.help if display_help
      end

      # .jarファイルを翻訳してリソースパックを作成する
      #
      # @param [String] file_path ファイルのパス
      # @param [Boolean] loggable 翻訳ログを出力するか
      # @param [Boolean] tierdown リソースパック作成後に不要なファイルを削除するか
      # @return [void]
      def perform(file_path, loggable: true, tierdown: true)
        @loggable, @tierdown = loggable, tierdown
        file_path = File.expand_path(file_path)
        validate_path(file_path)

        init_reader_and_writer(file_path)
        lang_data = @reader.extract_lang_json_and_meta_data
        init_progress_bar(file_path, lang_data.json.length) if @loggable

        need_translation?(lang_data) ? translate(lang_data) : feedback_unnecessary_translation(lang_data)
      end

      # ディレクトリ内の.jarファイルを翻訳してリソースパックを作成する
      #
      # @param [String] dir_path ディレクトリのパス
      # @param [Boolean] loggable 翻訳ログを出力するか
      # @return [void]
      def perform_directory(dir_path: "mods", loggable: true)
        puts "Performing directory: #{dir_path}" unless loggable
        dir_path = File.expand_path(dir_path)
        validate_path(dir_path)

        jar_files = Dir.glob("#{dir_path}/*.jar")
        if jar_files.empty?
          puts "JAR files not found in: #{dir_path}"
          return
        end

        jar_files.each { |file_path| perform(file_path, loggable: loggable, tierdown: false) }
        @writer.remove_before_zipping_directory
      end

      # ファイルの存在性のバリデーション
      #
      # @param [String] path ファイルのパス
      # @return [void]
      def validate_path(path)
        path = File.expand_path(path)
        raise ModpackLocalizer::PathNotFoundError.new(path) unless File.exist?(path)
      end

      private

      # ReaderとWriterを初期化する
      #
      # @params [String] file_path ファイルのパス
      # @return [void]
      def init_reader_and_writer(file_path)
        @reader = ModpackLocalizer::JAR::Reader.new(file_path, @language, @country_name, @locale_code)
        @writer = ModpackLocalizer::JAR::Writer.new
      end

      # プログレスバーを初期化する
      #
      # @param [String] file_path ファイルのパス
      # @param [Integer] length プログレスバーの長さ
      # @return [void]
      def init_progress_bar(file_path, length)
        @progress_bar = ModpackLocalizer.create_progress_bar(file_path, length)
      end

      # 翻訳が必要か判定する
      #
      # @param [LangData] lang_data Readerから取得したデータ
      # @return [Boolean]
      def need_translation?(lang_data)
        lang_data.need_translation
      end

      # 翻訳を実行する
      #
      # @param [LangData] lang_data Readerから取得したデータ
      # @return [void]
      def translate(lang_data)
        lang_data.json.each do |key, value|
          retries = 0
          begin
            lang_data.json[key] = TranslationAPI.translate(value)
          rescue StandardError => e
            retries += 1
            raise e unless retries <= MAX_RETRIES

            sleep_time = sleep_time(retries)
            puts "Translation failed, retrying... (#{retries}/#{MAX_RETRIES}) waiting #{sleep_time.round(2)} seconds"
            sleep(sleep_time)
            retry
          end
          @progress_bar.increment if @loggable
        end

        @writer.make_resource_pack(lang_data)
        @writer.remove_before_zipping_directory if @tierdown
        puts "Mod translation completed!"
      end

      # 翻訳が不要な場合のフィードバックを出力する
      #
      # @param [LangData] lang_data Readerから取得したデータ
      # @return [void]
      def feedback_unnecessary_translation(lang_data)
        return unless @loggable

        @progress_bar.finish
        puts lang_data.message || already_has_translated_file_message(lang_data)
      end

      # 既に翻訳済みのファイルが存在する旨のメッセージを出力する
      #
      # @param [LangData] lang_data Readerから取得したデータ
      # @return [String]
      def already_has_translated_file_message(lang_data)
        "#{camelize(lang_data.mod_name)} already has #{@reader.extract_file_name(lang_data.file_name)} file."
      end

      def sleep_time(retries)
        [BASE_DELAY * (retries**2), MAX_SLEEP].min
      end

      def camelize(str)
        str.split("_").map(&:capitalize).join
      end
    end
  end
end
