require "jp_translator_from_gpt"
require_relative "help"
require_relative "error"
require_relative "reader"
require_relative "writer"

module JpQuest
  class Performer
    # @param [Boolean] output_logs ログを出力するか
    # @param [Array<String>] except_words 翻訳しない単語
    # @param [String] exchange_language どの言語に翻訳するか
    # @param [Boolean] display_help ヘルプを表示するか
    # @return [JpQuest::Performer]
    def initialize(output_logs: true, except_words: [], exchange_language: "japanese", display_help: true)
      @translator = JpTranslatorFromGpt::Translator.new(
        output_logs: output_logs,
        except_words: except_words,
        exchange_language: exchange_language
      )
      @progress_bar = nil

      JpQuest.help if display_help
    end

    # ファイルを翻訳して出力する
    #
    # @param [String] file_path ファイルのパス
    # @return [void]
    def perform(file_path)
      file_path = File.expand_path(file_path)
      validate_path(file_path)

      reader = JpQuest::Reader.new(file_path)
      results = reader.extract_all.flatten
      writer = JpQuest::Writer.new(file_path)
      @progress_bar = JpQuest.create_progress_bar(file_path, results.length)
      results.each do |result|
        # TODO: なぜか4行ずれることがある
        puts "start_line: #{result[:start_line]}, end_line: #{result[:end_line]}, indent: #{result[:indent]}"
        result[:text] = @translator.translate(result[:text])
        writer.overwrites(result)
        @progress_bar.increment
      end
    end

    # ディレクトリ内のファイルを翻訳して出力する
    #
    # @param [String] dir_path ディレクトリのパス
    # @return [void]
    def perform_directly(dir_path: "quests")
      dir_path = File.expand_path(dir_path)
      validate_path(dir_path)

      # **でサブディレクトリも含めて取得
      Dir.glob("#{dir_path}/**.snbt").each do |file_path|
        perform(file_path)
      end
    end

    # ファイルの存在を確認する
    # 存在しない場合はPathNotFoundErrorを投げる
    #
    # @param [String] path ファイルのパス
    # @return [void]
    def validate_path(path)
      path = File.expand_path(path)
      raise JpQuest::PathNotFoundError.new(path) unless File.exist?(path)
    end
  end
end
