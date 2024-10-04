module JpQuest
  module SubtitleExtractor
    # subtitle: "some subtitle"を抽出する
    #
    # @param [String] file_path ファイルのパス
    # @return [Array<Hash>] サブタイトルと行番号の配列
    def extract_subtitles(file_path)
      subtitles = []
      File.open(file_path, "r").each_with_index do |line, index|
        subtitles << { subtitle: extract_oneline(line), line: index + 1 } if start_of?(line, key: :subtitle)
      end
      subtitles
    end
  end
end
