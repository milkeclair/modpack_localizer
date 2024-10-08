module JpQuest
  # 基底のエラークラス
  class Error < StandardError; end

  # パスが見つからない場合のエラークラス
  class PathNotFoundError < Error
    # ヒアドキュメントを使うと、先頭と末尾に空行が入る
    # エラーメッセージも変更しやすいのでこうしている
    DOES_NOT_EXIST = <<~TEXT.freeze
      \n
      Path does not exist: %s
    TEXT

    # @param [String] path パス
    # @return [JpQuest::PathNotFoundError]
    def initialize(path)
      super(format(DOES_NOT_EXIST, path))
    end
  end

  # 行数が異なる場合のエラークラス
  class InvalidLineCountError < Error
    INVALID_LINE_COUNT = <<~TEXT.freeze
      \n
      Invalid line count: %s
    TEXT

    # @param [Integer] expect_count 期待する行数
    # @param [Integer] actual_count 実際の行数
    # @return [JpQuest::InvalidLineCountError]
    def initialize(expect_count, actual_count)
      super(format(INVALID_LINE_COUNT, "Expected: #{expect_count}, Actual: #{actual_count}"))
    end
  end
end
