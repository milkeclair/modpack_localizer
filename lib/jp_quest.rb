# frozen_string_literal: true

require "jp_translator_from_gpt"
require_relative "jp_quest/version"
require_relative "jp_quest/help"
require_relative "jp_quest/error"
require_relative "jp_quest/reader"

module JpQuest
  class Performer
    # @param [Boolean] output_logs ログを出力するか
    # @param [Array<String>] except_words 翻訳しない単語
    # @param [String] exchange_language どの言語に翻訳するか
    # @param [Boolean] display_help ヘルプを表示するか
    # @return [JpQuest::Performer]
    def initialize(output_logs: true, except_words: [], exchange_language: "japanese", display_help: false)
      @translator = JpTranslatorFromGpt::Translator.new(
        output_logs: output_logs,
        except_words: except_words,
        exchange_language: exchange_language
      )

      JpQuest.help if display_help
    end

    # ファイルを翻訳して出力する
    #
    # @param [String] file_path ファイルのパス
    # @return [void]
    def perform(file_path)
      file_path = File.expand_path(file_path)
      validate_path(file_path)

      # TODO: 翻訳後の行数が元の行数と異なる場合、元の行数分後ろに空行を追加する
      results = JpQuest::Reader.new(file_path).extract_descriptions
      puts "file_path: #{file_path}"
      puts "results: #{results.length}"
      results.each do |r|
        puts r[:description]
        puts "start_line: #{r[:start_line]}, end_line: #{r[:end_line]}, indent: #{r[:indent]}"
        # translated_text = @translator.translate(r[:description])
        # puts translated_text
        puts "----------------"
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
