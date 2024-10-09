require_relative "indent_helper"

module JpQuest
  # 翻訳された内容をSNBT形式に整形するクラス
  class Formatter
    include IndentHelper

    # 保存できるように整形
    #
    # @param [Hash] content コンテンツ
    # @param [String] indent インデント
    # @return [String] SNBT形式に整形したコンテンツ
    def format_overwritable_lines(content, indent)
      full_lines = add_missing_lines(content)
      format_for_snbt(full_lines, indent, content)
    end

    # SNBT形式に整形
    #
    # @param [Array<String>] lines 行
    # @param [String] indent インデント
    # @param [Hash] content コンテンツ
    # @return [String] SNBT形式に整形した行
    def format_for_snbt(lines, indent, content)
      lines = prepare_lines_for_snbt(lines, content)
      formatted_lines = format_lines(lines, indent, content)
      "#{indent}#{content[:type]}: #{formatted_lines}"
    end

    # 不足している行を追加
    #
    # @param [Hash] content コンテンツ
    # @return [void]
    def add_missing_lines(content)
      required_lines = extract_required_line_counts(content)
      lines = content[:text].split("\n")

      while lines.length < required_lines
        lines << empty_middle_line(content[:indent])
      end

      lines
    end

    private

    # 不要な文字を削除する
    #
    # @param [String] lines 行
    # @param [Hash] content コンテンツ
    # @return [Array<String>] 不要な文字を削除した行
    def prepare_lines_for_snbt(lines, content)
      lines.map! { |line| delete_quotes(line) }
      lines.map!(&:strip) unless content[:type] == :description
      lines
    end

    # SNBT形式に変換しやすい形に整形
    #
    # @param [Array<String>] lines 行
    # @param [String] indent インデント
    # @param [Hash] content コンテンツ
    # @return [String] SNBT形式に変換しやすく整形した行
    def format_lines(lines, indent, content)
      if lines.length == 1
        content[:type] == :description ? "[#{lines[0].strip}]" : lines[0].strip.to_s
      else
        # [
        #   "Hello"
        #   "World"
        # ]
        mid_indent = middle_indent(content[:indent])
        lines = lines.map { |line| "#{mid_indent}#{line.strip}" }
        "[\n#{lines.join("\n")}\n#{indent}]"
      end
    end

    # 必要な行数を抽出
    #
    # @param [Hash] content コンテンツ
    # @return [Integer] 必要な行数
    def extract_required_line_counts(content)
      # start_lineが1、end_lineが5の場合、必要な行数はブラケットを抜いて3行
      # そのため、(end(5) - start(1)) + 1行 - ブラケット2行 = 3行となる
      line_offset, without_brackets = 1, 2

      (content[:end_line] - content[:start_line]) + line_offset - without_brackets
    end

    # 中間行の空行を作成
    #
    # @return [String] 空行
    def empty_middle_line(indent)
      middle_indent(indent).to_s
    end

    # 不要な引用符を削除
    #
    # @param [String] line 行
    # @return [String] 不要な引用符を削除した行
    def delete_quotes(line)
      line = delete_dup_quotes(line)
      line = delete_jp_quotes(line)
      delete_curved_quotes(line)
    end

    # 不要なダブルクオートを削除
    #
    # @param [String] line 行
    # @return [String] 不要なダブルクオートを削除した行
    def delete_dup_quotes(line)
      # 行間にある余計なダブルクオートを削除するため、一度全てのダブルクオートを削除している
      # 全て削除したあと、行頭、行末にダブルクオートを追加する
      line = line.gsub('"', "")
      line_start = /^(\s*)/
      line = line.sub(line_start, "\"")
      "#{line}\""
    end

    # 不要な鍵括弧を削除
    #
    # @param [String] line 行
    # @return [String] 不要な鍵括弧を削除した行
    def delete_jp_quotes(line)
      # 「Hello」
      deletable_reg = /「.*」/
      return line unless line.match?(deletable_reg)

      jp_quotes = [/「/, /」/]
      jp_quotes.each { |quo| line = line.gsub(quo, "") }
      line
    end

    # 不要な曲がった引用符を削除
    #
    # @param [String] line 行
    # @return [String] 不要な曲がった引用符を削除した行
    def delete_curved_quotes(line)
      # “Hello”
      deletable_reg = /“.*”/
      return line unless line.match?(deletable_reg)

      curved_quotes = [/“/, /”/]
      curved_quotes.each { |quo| line = line.gsub(quo, "") }
      line
    end
  end
end
