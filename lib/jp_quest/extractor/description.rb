module JpQuest
  module DescriptionExtractor
    def extract_descriptions(file_path)
      descs = []
      desc_content = []
      start_line = nil

      File.open(file_path, "r").each_with_index do |line, index|
        stripped_line = line.strip

        if oneline_description?(stripped_line)
          descs << build_oneline_description(stripped_line, index)
        elsif start_of_description?(stripped_line)
          start_line, desc_content = handle_start_of_description(line, index)
        elsif end_of_description?(stripped_line, start_line)
          descs << build_multiline_description(desc_content, start_line, index, stripped_line)
          start_line = nil
        elsif middle_of_description?(stripped_line, start_line)
          desc_content << stripped_line
        end
      end

      descs
    end

    private

    def end_of_description?(line, start_line)
      line.strip.end_with?("]") && start_line
    end

    def middle_of_description?(line, start_line)
      line.strip != "]" && start_line
    end

    def handle_start_of_description(line, index)
      start_line = index + 1
      desc_content = [extract_oneline(line, is_desc: true)]
      [start_line, desc_content]
    end

    def build_oneline_description(line, index)
      {
        description: extract_oneline(line, is_desc: true),
        start_line: index + 1,
        end_line: index + 1
      }
    end

    def build_multiline_description(content, start_line, index, line)
      content << extract_oneline(line, is_desc: true)
      {
        description: content.join("\n"),
        start_line: start_line,
        end_line: index + 1
      }
    end

    def start_of_description?(line)
      start_of?(line, key: :description)
    end
  end
end
