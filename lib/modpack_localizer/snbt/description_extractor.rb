require_relative "../util/indent_helper"

module ModpackLocalizer
  module SNBT
    # SNBT形式のファイルからdescription: ["some description"]を抽出するモジュール
    module DescriptionExtractor
      include IndentHelper

      # description: ["some description"]を抽出する
      #
      # @param [String] file_path ファイルのパス
      # @return [Array<Hash>] 説明、開始行番号、終了行番号の配列
      def extract_descriptions(file_path)
        lines = File.readlines(file_path)
        extract_from_file(lines)
      end

      private

      # ファイルから説明を抽出する
      #
      # @param [Array<String>] lines 行の配列
      # @return [Array<Hash>] 説明、開始行番号、終了行番号、インデントのハッシュの配列
      def extract_from_file(lines)
        descs = []
        desc_content = []
        start_line = nil

        lines.each_with_index do |line, index|
          indent = count_indent(line)

          # 1行の説明の場合はそのままハッシュに変換
          # 複数行の場合は、開始行と終了行の間の説明を抽出する
          if oneline?(line)
            descs << build_oneline(line, index, indent)
          elsif start_line?(line)
            start_line = index
          elsif middle_line?(line, start_line)
            desc_content << line.strip
          elsif end_line?(line, start_line)
            descs << build_multiline(desc_content, start_line, index, indent)
            start_line = nil
            desc_content = []
          end
        end

        descs
      end

      # 1行かどうか
      #
      # @param [String] line 行
      # @return [Boolean]
      def oneline?(line)
        oneline_description?(line)
      end

      # 開始行かどうか
      #
      # @param [String] line 行
      # @return [Boolean]
      def start_line?(line)
        start_of?(line, key: :description)
      end

      # 終了行かどうか
      #
      # @param [String] line 行
      # @param [Integer] start_line 開始行番号
      # @return [Boolean]
      def end_line?(line, start_line)
        line.strip.end_with?("]") && start_line
      end

      # 中間行かどうか
      #
      # @param [String] line 行
      # @param [Integer] start_line 開始行番号
      # @return [Boolean]
      def middle_line?(line, start_line)
        line.strip != "]" && start_line
      end

      # 1行の処理
      #
      # @param [String] line 行
      # @param [Integer] index 行番号
      # @param [Integer] indent インデント
      # @return [Hash] 説明、開始行番号、終了行番号、インデントのハッシュ
      def build_oneline(line, index, indent)
        {
          type: :description,
          text: extract_oneline(line, is_desc: true),
          start_line: index,
          end_line: index,
          indent: indent
        }
      end

      # 複数行の処理
      #
      # @param [Array<String>] content 説明の配列
      # @param [Integer] start_line 開始行番号
      # @param [Integer] index 行番号
      # @param [Integer] indent インデント
      # @return [Hash] 説明、開始行番号、終了行番号、インデントのハッシュ
      def build_multiline(content, start_line, index, indent)
        {
          type: :description,
          text: content.join("\n"),
          start_line: start_line,
          end_line: index,
          indent: indent
        }
      end
    end
  end
end
