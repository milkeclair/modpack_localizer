module JpQuest
  module TitleExtractor
    # title: "some title"を抽出する
    #
    # @param [String] file_path ファイルのパス
    # @return [Array<Hash>] タイトルと行番号の配列
    def extract_titles(file_path)
      titles = []
      File.open(file_path, "r").each_with_index do |line, index|
        titles << { title: extract_oneline(line), line: index + 1 } if start_of?(line, key: :title)
      end
      titles
    end
  end
end
