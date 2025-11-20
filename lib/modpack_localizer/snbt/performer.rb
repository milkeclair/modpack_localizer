require "translation_api"
require_relative "../util/help"
require_relative "../util/error"
require_relative "reader"
require_relative "writer"

module ModpackLocalizer
  module SNBT
    # .snbtの翻訳を実行するクラス
    class Performer
      MAX_RETRIES = 8
      BASE_DELAY = 5
      MAX_SLEEP = 256

      # @param [Boolean] output_logs APIのログを出力するか
      # @param [Array<String>] except_words 翻訳しない単語
      # @param [String] language 言語
      # @param [Boolean] display_help ヘルプを表示するか
      # @return [ModpackLocalizer::SNBT::Performer]
      def initialize(output_logs: true, except_words: [], language: "Japanese", display_help: true)
        TranslationAPI.configure do |config|
          config.output_logs  = output_logs
          config.language     = language
          config.except_words = except_words
          config.provider     = :openai
        end

        @reader, @writer, @progress_bar, @loggable = nil

        ModpackLocalizer.help if display_help
      end

      # .snbtファイルを翻訳して出力する
      #
      # @param [String] file_path ファイルのパス
      # @param [Boolean] loggable 翻訳ログを出力するか
      # @return [void]
      def perform(file_path, loggable: true)
        @loggable = loggable
        file_path = File.expand_path(file_path)
        validate_path(file_path)

        @reader, @writer = ModpackLocalizer::SNBT::Reader.new(file_path), ModpackLocalizer::SNBT::Writer.new(file_path)
        results = @reader.extract_all.flatten
        init_progress_bar(file_path, results.length) if @loggable

        results.each do |result|
          result[:snbt] = retryable_translate(result[:text])
          @writer.overwrites(result)
          @progress_bar.increment if @loggable
        end

        puts "Quest translation completed!"
      end

      # ディレクトリ内の.snbtファイルを翻訳して出力する
      #
      # @param [String] dir_path ディレクトリのパス
      # @param [Boolean] loggable 翻訳ログを出力するか
      # @return [void]
      def perform_directory(dir_path: "quests", loggable: true)
        puts "Performing directory: #{dir_path}" unless loggable
        dir_path = File.expand_path(dir_path)
        validate_path(dir_path)

        # **でサブディレクトリも含めて取得
        snbt_files = Dir.glob("#{dir_path}/**/*.snbt")
        if snbt_files.empty?
          puts "SNBT files not found in: #{dir_path}"
          return
        end

        snbt_files.each { |file_path| perform(file_path, loggable: loggable) }
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

      def retryable_translate(text)
        retries = 0
        begin
          TranslationAPI.translate(text)
        rescue StandardError => e
          retries += 1
          raise e unless retries <= MAX_RETRIES

          sleep_time = sleep_time(retries)
          puts "Translation failed, retrying... (#{retries}/#{MAX_RETRIES}) waiting #{sleep_time.round(2)} seconds"
          sleep(sleep_time)
          retry
        end
      end

      def sleep_time(retries)
        [BASE_DELAY * (retries**2), MAX_SLEEP].min
      end

      # プログレスバーを初期化する
      #
      # @param [String] file_path ファイルのパス
      # @param [Integer] length プログレスバーの長さ
      # @return [void]
      def init_progress_bar(file_path, length)
        @progress_bar = ModpackLocalizer.create_progress_bar(file_path, length)
      end
    end
  end
end
