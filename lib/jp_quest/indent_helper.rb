module JpQuest
  module IndentHelper
    # インデントを作成
    #
    # @param [Integer] indent インデント数
    # @return [String] インデント
    def create_indent(indent)
      "  " * indent
    end

    # 中間行のインデントを作成
    #
    # @param [Integer] indent インデント数
    # @return [String] 中間行のインデント
    def middle_indent(indent)
      "  " * (indent + 1)
    end

    # インデントを調整
    #
    # @param [Integer] indent インデント数
    # @return [Integer] 調整後のインデント数
    def normalize_indent(indent)
      dup_indent = 12
      if indent > dup_indent
        half = 2
        half_indent = indent / half
        # インデントの数は偶数にする
        half_indent.even? ? half_indent : half_indent + 1
      else
        indent
      end
    end
  end
end
