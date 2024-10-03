module JpQuest
  module DescriptionExtractor
    # TODO: ネストが深いのでリファクタリングする
    def extract_descriptions(file_path)
      descriptions = []
      description_content = []
      start_line = nil

      File.open(file_path, "r").each_with_index do |line, index|
        stripped_line = line.strip

        if oneline_description?(stripped_line)
          descriptions << {
            description: extract_oneline(stripped_line, is_desc: true),
            start_line: index + 1,
            end_line: index + 1
          }
        elsif start_of?(line, key: :description)
          start_line = index + 1
          description_content = [extract_oneline(stripped_line, is_desc: true)]
        elsif end_of_description?(stripped_line, start_line)
          description_content << extract_oneline(stripped_line, is_desc: true)
          descriptions << {
            description: description_content.join("\n"),
            start_line: start_line,
            end_line: index + 1
          }
          start_line = nil
        elsif middle_of_description?(stripped_line, start_line)
          description_content << stripped_line
        end
      end

      descriptions
    end
  end
end
