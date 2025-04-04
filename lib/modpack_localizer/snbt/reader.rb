# frozen_string_literal: true

require_relative "../util/indent_helper"
require_relative "title_extractor"
require_relative "subtitle_extractor"
require_relative "description_extractor"

module ModpackLocalizer
  module SNBT
    # .snbtファイルからタイトル、サブタイトル、説明を抽出するクラス
    class Reader
      include TitleExtractor
      include SubtitleExtractor
      include DescriptionExtractor

      DESC_START_LENGTH = 14
      DESC_END_LENGTH = -2

      # @param [String] file_path ファイルのパス
      # @return [ModpackLocalizer::SNBT::Reader]
      def initialize(file_path)
        @file_path = file_path
      end

      # タイトル、サブタイトル、説明を抽出する
      #
      # @return [Array<Array<Hash>>] タイトル、サブタイトル、説明の配列
      def extract_all
        titles = extract_titles
        subtitles = extract_subtitles
        descriptions = extract_descriptions

        [titles, subtitles, descriptions]
      end

      # タイトルを抽出する
      #
      # @return [Array<Hash>] タイトル、行番号、インデントの配列
      def extract_titles
        super(@file_path)
      end

      # サブタイトルを抽出する
      #
      # @return [Array<Hash>] サブタイトル、行番号、インデントの配列
      def extract_subtitles
        super(@file_path)
      end

      # 説明を抽出する
      #
      # @return [Array<Hash>] 説明、開始行、終了行、インデントの配列
      def extract_descriptions
        super(@file_path)
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
        sections = {
          title: "title:",
          subtitle: "subtitle:",
          description: "description: ["
        }

        stripped_line.start_with?(sections[key])
      end
    end
  end
end
