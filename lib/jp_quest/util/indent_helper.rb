module JpQuest
  # インデントを扱うモジュール
  module IndentHelper
    # インデントを数える
    #
    # @param [String] unstripped_line stripされていない行
    # @return [Integer] インデントの数
    def count_indent(unstripped_line)
      unstripped_line.length - unstripped_line.lstrip.length
    end

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
  end
end
