module JpQuest
  module DescriptionExtractor
    # description: ["some description"]を抽出する
    #
    # @param [String] file_path ファイルのパス
    # @return [Array<Hash>] 説明、開始行番号、終了行番号の配列
    def extract_descriptions(file_path)
      descs = []
      desc_content = []
      start_line = nil

      File.open(file_path, "r").each_with_index do |line, index|
        indent = count_indent(line)

        if oneline?(line)
          descs << build_oneline(line, index, indent)
        elsif start_line?(line)
          start_line, desc_content = handle_start_line(line, index)
        elsif end_line?(line, start_line)
          descs << build_multiline(desc_content, line, start_line, index, indent)
          start_line = nil
        elsif middle_line?(line, start_line)
          desc_content << line.strip
        end
      end

      descs
    end

    private

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

    # 開始行の処理
    #
    # @param [String] line 行
    # @param [Integer] index 行番号
    # @return [Array<Integer, Array<String>>] 開始行番号と説明の配列
    def handle_start_line(line, index)
      start_line = index + 1
      desc_content = [extract_oneline(line, is_desc: true)]
      [start_line, desc_content]
    end

    # 1行の処理
    #
    # @param [String] line 行
    # @param [Integer] index 行番号
    # @param [Integer] indent インデント
    # @return [Hash] 説明、開始行番号、終了行番号、インデントのハッシュ
    def build_oneline(line, index, indent)
      {
        description: extract_oneline(line, is_desc: true),
        start_line: index + 1,
        end_line: index + 1,
        indent: indent
      }
    end

    # 複数行の処理
    #
    # @param [Array<String>] content 説明の配列
    # @param [String] line 行
    # @param [Integer] start_line 開始行番号番号番号
    # @param [Integer] index 行番号
    # @param [Integer] indent インデント
    # @return [Hash] 説明、開始行番号、終了行番号のハッシュ
    def build_multiline(content, line, start_line, index, indent)
      content << extract_oneline(line, is_desc: true)
      {
        description: delete_empty_lines(content).join("\n"),
        start_line: start_line,
        end_line: index + 1,
        indent: indent
      }
    end

    # 空の行を削除する
    #
    # @param [Array<String>] content 説明の配列
    # @return [Array<String>] 空の行を削除した説明の配列
    def delete_empty_lines(content)
      content.reject { |c| c.strip.empty? }
    end
  end
end
