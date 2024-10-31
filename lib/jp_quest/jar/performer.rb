require "jp_translator_from_gpt"
require "active_support/core_ext/string/inflections"
require_relative "../util/help"
require_relative "../util/error"
require_relative "reader"
require_relative "writer"

module JpQuest
  module JAR
    # .jarの翻訳を実行するクラス
    # JpTranslatorFromGptを使用して翻訳を行う
    class Performer
      # region_codeを指定する場合、countryの指定は不要
      #
      # @param [Boolean] output_logs APIのログを出力するか
      # @param [Array<String>] except_words 翻訳しない単語
      # @param [String] language 言語
      # @param [String] country 国
      # @param [String] region_code 地域コード (例: "ja_jp")
      # @param [Boolean] display_help ヘルプを表示するか
      # @return [JpQuest::JAR::Performer]
      def initialize(
        output_logs: true, except_words: [], language: "Japanese",
        country: "Japan", region_code: nil, display_help: true
      )
        @translator = JpTranslatorFromGpt::Translator.new(
          output_logs: output_logs,
          except_words: except_words,
          exchange_language: language
        )
        @language, @country_name, @region_code = language, country, region_code
        @reader, @writer, @progress_bar, @loggable = nil

        JpQuest.help if display_help
      end

      # .jarファイルを翻訳してリソースパックを作成する
      #
      # @param [String] file_path ファイルのパス
      # @param [Boolean] loggable 翻訳ログを出力するか
      # @return [void]
      def perform(file_path, loggable: true)
        @loggable = loggable
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

        jar_files.each { |file_path| perform(file_path, loggable: loggable) }
      end

      # ファイルの存在性のバリデーション
      #
      # @param [String] path ファイルのパス
      # @return [void]
      def validate_path(path)
        path = File.expand_path(path)
        raise JpQuest::PathNotFoundError.new(path) unless File.exist?(path)
      end

      private

      # ReaderとWriterを初期化する
      #
      # @params [String] file_path ファイルのパス
      # @return [void]
      def init_reader_and_writer(file_path)
        @reader = JpQuest::JAR::Reader.new(file_path, @language, @country_name, @region_code)
        @writer = JpQuest::JAR::Writer.new
      end

      # プログレスバーを初期化する
      #
      # @param [String] file_path ファイルのパス
      # @param [Integer] length プログレスバーの長さ
      # @return [void]
      def init_progress_bar(file_path, length)
        @progress_bar = JpQuest.create_progress_bar(file_path, length)
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
          # lang_data.json[key] = @translator.translate(value)
          @progress_bar.increment if @loggable
        end

        @writer.make_resource_pack(lang_data)
        puts "Mod translation completed!"
      end

      # 翻訳が不要な場合のフィードバックを出力する
      #
      # @param [LangData] lang_data Readerから取得したデータ
      # @return [void]
      def feedback_unnecessary_translation(lang_data)
        return unless @loggable

        @progress_bar.finish
        puts already_has_translated_file_message(lang_data)
      end

      # 既に翻訳済みのファイルが存在する旨のメッセージを出力する
      #
      # @param [LangData] lang_data Readerから取得したデータ
      # @return [String]
      def already_has_translated_file_message(lang_data)
        "#{lang_data.mod_name.camelize} already has #{@reader.extract_file_name(lang_data.file_name)} file."
      end
    end
  end
end
