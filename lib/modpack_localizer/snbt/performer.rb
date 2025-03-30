require "translation_api"
require_relative "../util/help"
require_relative "../util/error"
require_relative "reader"
require_relative "writer"

module ModpackLocalizer
  module SNBT
    # .snbtの翻訳を実行するクラス
    class Performer
      # @param [Boolean] output_logs APIのログを出力するか
      # @param [Array<String>] except_words 翻訳しない単語
      # @param [String] language 言語
      # @param [Boolean] display_help ヘルプを表示するか
      # @return [ModpackLocalizer::SNBT::Performer]
      def initialize(output_logs: true, except_words: [], language: "Japanese", display_help: true)
        @translator = TranslationAPI::Mediator.new(
          output_logs: output_logs,
          except_words: except_words,
          language: language,
          agent: :openai
        )
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
          result[:text] = @translator.translate(result[:text])
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
