# frozen_string_literal: true

require_relative "extractor/title"
require_relative "extractor/subtitle"
require_relative "extractor/description"

module JpQuest
  class Reader
    include TitleExtractor
    include SubtitleExtractor
    include DescriptionExtractor

    DESC_START_LENGTH = 14
    DESC_END_LENGTH = -2

    def initialize(file_path)
      @file_path = file_path
    end

    def extract_titles
      super(@file_path)
    end

    def extract_subtitles
      super(@file_path)
    end

    def extract_descriptions
      super(@file_path)
    end

    private

    def extract_oneline(line, is_desc: false)
      return line.strip.split(":", 2)[1] unless is_desc

      if oneline_description?(line)
        line[DESC_START_LENGTH..DESC_END_LENGTH].strip
      elsif start_of?(line, key: :description)
        line.strip.split("[", 2)[1]
      else
        line.strip.split("]", 2)[0]
      end
    end

    def oneline_description?(line)
      start_of?(line, key: :description) && line.strip.end_with?("]")
    end

    def start_of?(line, key:)
      case key
      when :title
        line.strip.start_with?("title:")
      when :subtitle
        line.strip.start_with?("subtitle:")
      when :description
        line.strip.start_with?("description: [")
      end
    end
  end
end
