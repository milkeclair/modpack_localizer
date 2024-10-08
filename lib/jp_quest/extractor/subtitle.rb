module JpQuest
  # SNBT形式のファイルからsubtitle: "some subtitle"を抽出するモジュール
  module SubtitleExtractor
    # subtitle: "some subtitle"を抽出する
    #
    # @param [String] file_path ファイルのパス
    # @return [Array<Hash>] サブタイトルと行番号の配列
    def extract_subtitles(file_path)
      subtitles = []
      lines = File.readlines(file_path)
      lines.each_with_index do |line, index|
        next unless start_of?(line, key: :subtitle)

        subtitles << {
          type: :subtitle,
          text: extract_oneline(line),
          start_line: index,
          end_line: index,
          indent: count_indent(line)
        }
      end

      subtitles
    end
  end
end
