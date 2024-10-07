require_relative "indent_helper"

module JpQuest
  class Formatter
    include IndentHelper

    # 保存できるように整形
    #
    # @param [Hash] content コンテンツ
    # @param [String] indent インデント
    # @return [String] 整形したコンテンツ
    def format_overwritable_lines(content, indent)
      mid_indent = middle_indent(content[:indent])
      indented_lines = add_indent_for_middle_lines(content, mid_indent)

      add_missing_lines(indented_lines, content, mid_indent)
      format_for_snbt(indented_lines, indent, content[:type])
    end

    # SNBT形式に整形
    #
    # @param [Array<String>] lines 行
    # @param [String] indent インデント
    # @param [Symbol] type コンテンツの種類
    # @return [String] SNBT形式に整形した行
    def format_for_snbt(lines, indent, type)
      lines.map! { |line| delete_quotes(line) }
      lines.map!(&:strip) unless type == :description

      formatted_lines =
        if lines.size == 1
          type == :description ? "[#{lines[0].strip}]" : lines[0].strip.to_s
        else
          # description: [
          #   "Hello"
          #   "World"
          # ]
          "[\n#{lines.join("\n")}\n#{indent}]"
        end

      # "   description: ["hoge"]"のような形式にする
      "#{indent}#{type}: #{formatted_lines}"
    end

    # 不足している行を追加
    #
    # @param [Array<String>] lines 行
    # @param [Hash] content コンテンツ
    # @param [String] middle_indent 中間行のインデント
    # @return [void]
    def add_missing_lines(lines, content, middle_indent)
      return if lines.size == 1

      required_lines = extract_required_line_counts(content)

      while lines.size < required_lines
        lines << empty_middle_line(middle_indent)
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

    # 中間行のインデントを追加
    #
    # @param [Hash] content コンテンツ
    # @param [String] middle_indent 中間行のインデント
    # @return [Array<String>] 中間行のインデントを追加した行
    def add_indent_for_middle_lines(content, middle_indent)
      content[:text].split("\n").map do |line|
        "#{middle_indent}\"#{line}\""
      end
    end

    # 中間行の空行を作成
    #
    # @param [String] middle_indent 中間行のインデント
    # @return [String] 空行
    def empty_middle_line(middle_indent)
      "#{middle_indent}\"\""
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

    private

    # 不要なダブルクオートを削除
    #
    # @param [String] line 行
    # @return [String] 不要なダブルクオートを削除した行
    def delete_dup_quotes(line)
      # ""Hello""、""""
      deletable_regs = [/"{2,}.+".*"/, /"{3,}/]
      return line unless deletable_regs.any? { |reg| line.match?(reg) }

      # ""
      dup_reg = /"{2,}/
      # """"に一致する場合は空白行なので、""に変換する
      if line.strip.match?(deletable_regs[1])
        line.gsub(dup_reg, '""')
      else
        line = line.gsub('"', "")
        # インデントの調整と行頭のダブルクオートの追加
        indent_count = normalize_indent(line[/^\s*/].size)
        line = line.sub(/^(\s*)/, "#{" " * indent_count}\"")
        # 行末のダブルクオート
        "#{line}\""
      end
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
