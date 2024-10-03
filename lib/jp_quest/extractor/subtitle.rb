module JpQuest
  module SubtitleExtractor
    def extract_subtitles(file_path)
      subtitles = []
      File.open(file_path, "r").each_with_index do |line, index|
        if start_of?(line, key: :subtitle)
          subtitles << { subtitle: extract_oneline(line), line: index + 1 }
        end
      end
      subtitles
    end
  end
end
