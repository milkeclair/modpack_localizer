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

    # @param [String] file_path ファイルのパス
    # @return [JpQuest::Reader]
    def initialize(file_path)
      @file_path = file_path
    end

    # タイトルを抽出する
    #
    # @return [Array<Hash>] タイトルと行番号の配列
    def extract_titles
      super(@file_path)
    end

    # サブタイトルを抽出する
    #
    # @return [Array<Hash>] サブタイトルと行番号の配列
    def extract_subtitles
      super(@file_path)
    end

    # 説明を抽出する
    #
    # @return [Array<Hash>] 説明、開始行、終了行の配列
    def extract_descriptions
      super(@file_path)
    end

    # インデントを数える
    #
    # @param [String] unstripped_line stripされていない行
    # @return [Integer] インデントの数
    def count_indent(unstripped_line)
      unstripped_line.length - unstripped_line.lstrip.length
    end

    # title: "some title"のような形式から、"some title"を抽出する
    # 説明の場合は、description: ["some description"]のような形式から、"some description"を抽出する
    #
    # @param [String] line 行
    # @param [Boolean] is_desc 説明かどうか
    # @return [String] タイトル or サブタイトル or 説明
    def extract_oneline(line, is_desc: false)
      stripped_line = line.strip
      return stripped_line.split(":", 2)[1] unless is_desc

      if oneline_description?(line)
        stripped_line[DESC_START_LENGTH..DESC_END_LENGTH]
      elsif start_of?(line, key: :description)
        stripped_line.split("[", 2)[1]
      else
        stripped_line.split("]", 2)[0]
      end
    end

    # 1行の説明かどうか
    #
    # @param [String] line 行
    # @return [Boolean]
    def oneline_description?(line)
      stripped_line = line.strip
      start_of?(line, key: :description) && stripped_line.end_with?("]")
    end

    # どのコンテンツの開始行か
    #
    # @param [String] line 行
    # @param [Symbol] key コンテンツの種類
    # @return [Boolean]
    def start_of?(line, key:)
      stripped_line = line.strip

      case key
      when :title
        stripped_line.start_with?("title:")
      when :subtitle
        stripped_line.start_with?("subtitle:")
      when :description
        stripped_line.start_with?("description: [")
      end
    end
  end
end
