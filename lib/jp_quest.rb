# frozen_string_literal: true

require "jp_translator_from_gpt"
require_relative "jp_quest/version"
require_relative "jp_quest/reader"

module JpQuest
  class Performer
    # @param [Boolean] output_logs ログを出力するか
    # @param [Array<String>] except_words 翻訳しない単語
    # @param [String] exchange_language どの言語に翻訳するか
    # @return [JpQuest::Performer]
    def initialize(output_logs: true, except_words: [], exchange_language: "japanese")
      @translator = JpTranslatorFromGpt::Translator.new(
        output_logs: output_logs,
        except_words: except_words,
        exchange_language: exchange_language
      )
    end

    # ファイルを翻訳して出力する
    #
    # @param [String] file_path ファイルのパス
    # @return [void]
    def perform(file_path)
      # TODO: 翻訳後の行数が元の行数と異なる場合、元の行数分後ろに空行を追加する
      file = JpQuest::Reader.new(file_path).extract_descriptions
      puts file.length
      file.each do |f|
        puts f[:description]
        puts "start_line: #{f[:start_line]}, end_line: #{f[:end_line]}, indent: #{f[:indent]}"
        # translated_text = @translator.translate(f[:description])
        # puts translated_text
        puts "----------------"
      end
    end

    # ディレクトリ内のファイルを翻訳して出力する
    #
    # @param [String] dir_path ディレクトリのパス
    # @param [Boolean] full_path 絶対パスかどうか
    # @return [void]
    def perform_directly(dir_path, full_path: false)
      dir_path = File.expand_path(dir_path) if full_path
      Dir.glob("#{dir_path}/*.snbt").each do |file_path|
        perform(file_path)
      end
    end
  end
end
