# frozen_string_literal: true

require "jp_translator_from_gpt"
require_relative "jp_quest/version"
require_relative "jp_quest/reader"

module JpQuest
  class Performer
    def initialize(output_logs: true, except_words: [], exchange_language: "japanese")
      @translator = JpTranslatorFromGpt::Translator.new(
        output_logs: output_logs,
        except_words: except_words,
        exchange_language: exchange_language
      )
    end

    def perform(file_path)
      file = JpQuest::Reader.new(file_path).extract_descriptions
      puts file.length
      file.each do |f|
        puts f[:description]
        puts "start_line: #{f[:start_line]}, end_line: #{f[:end_line]}"
        puts "----------------"
        # translated_text = @translator.translate(f[:description])
        # p translated_text
        # puts "----------------"
      end
    end
  end
end
