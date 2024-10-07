module JpQuest
  module TitleExtractor
    # title: "some title"を抽出する
    #
    # @param [String] file_path ファイルのパス
    # @return [Array<Hash>] タイトルと行番号の配列
    def extract_titles(file_path)
      titles = []
      lines = File.readlines(file_path)
      lines.each_with_index do |line, index|
        next unless start_of?(line, key: :title)

        titles << {
          text: extract_oneline(line),
          line: index + 1,
          indent: count_indent(line)
        }
      end

      titles
    end
  end
end
