# frozen_string_literal: true

require "jp_translator_from_gpt"
require_relative "jp_quest/version"
require_relative "jp_quest/reader"

module JpQuest
  class Performer
    def initialize(output_logs: true, except_words: [])
      @translator = JpTranslatorFromGpt::Translator.new(output_logs: output_logs, except_words: except_words)
    end

    def perform(file_path)
      file = JpQuest::Reader.new(file_path).extract_descriptions
      puts file.length
      @translator.translate_to_jp(file)
    end
  end
end
