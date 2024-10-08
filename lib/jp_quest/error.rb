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
end
