module JpQuest
  # インデントを扱うモジュール
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
  end
end
