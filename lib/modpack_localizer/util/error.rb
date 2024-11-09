module ModpackLocalizer
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
    # @return [ModpackLocalizer::PathNotFoundError]
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
    # @return [ModpackLocalizer::InvalidLineCountError]
    def initialize(expect_count, actual_count)
      super(format(INVALID_LINE_COUNT, "Expected: #{expect_count}, Actual: #{actual_count}"))
    end
  end

  class InvalidRegionCodeError < Error
    INVALID_LOCALE_CODE = <<~TEXT.freeze
      \n
      %s is an invalid region code.
      Please specify a valid language or country or region code.
    TEXT

    def initialize(locale_code)
      super(format(INVALID_LOCALE_CODE, locale_code))
    end
  end
end
