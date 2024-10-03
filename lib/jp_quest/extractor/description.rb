module JpQuest
  module DescriptionExtractor
    def extract_descriptions(file_path)
      descs = []
      desc_content = []
      start_line = nil

      File.open(file_path, "r").each_with_index do |line, index|
        stripped_line = line.strip

        if oneline?(stripped_line)
          descs << build_oneline(stripped_line, index)
        elsif start_line?(stripped_line)
          start_line, desc_content = handle_start_line(line, index)
        elsif end_line?(stripped_line, start_line)
          descs << build_multiline(desc_content, start_line, index, stripped_line)
          start_line = nil
        elsif middle_line?(stripped_line, start_line)
          desc_content << stripped_line
        end
      end

      descs
    end

    private

    def oneline?(line)
      oneline_description?(line)
    end

    def start_line?(line)
      start_of?(line, key: :description)
    end

    def end_line?(line, start_line)
      line.strip.end_with?("]") && start_line
    end

    def middle_line?(line, start_line)
      line.strip != "]" && start_line
    end

    def handle_start_line(line, index)
      start_line = index + 1
      desc_content = [extract_oneline(line, is_desc: true)]
      [start_line, desc_content]
    end

    def build_oneline(line, index)
      {
        description: extract_oneline(line, is_desc: true),
        start_line: index + 1,
        end_line: index + 1
      }
    end

    def build_multiline(content, start_line, index, line)
      content << extract_oneline(line, is_desc: true)
      {
        description: delete_empty_lines(content).join("\n"),
        start_line: start_line,
        end_line: index + 1
      }
    end

    def delete_empty_lines(content)
      content.reject { |c| c.strip.empty? }
    end
  end
end
