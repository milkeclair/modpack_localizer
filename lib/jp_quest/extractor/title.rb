module JpQuest
  module TitleExtractor
    def extract_titles(file_path)
      titles = []
      File.open(file_path, "r").each_with_index do |line, index|
        titles << { title: extract_oneline(line), line: index + 1 } if start_of?(line, key: :title)
      end
      titles
    end
  end
end
