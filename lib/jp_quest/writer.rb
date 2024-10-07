module JpQuest
  class Writer
    def initialize(file_path)
      @file_path = file_path
    end

    def overwrite(translated_contents)
      lines = File.readlines(@file_path)
      overwrite_lines(lines, translated_contents)
      # File.open(@file_path, "w") do |file|
      #  file.puts(lines)
      # end
    end

    def overwrite_lines(lines, content)
      puts content
      line_index =
        if content[:line]
          content[:line] - 1
        else
          content[:start_line] - 1
        end

      indent = make_indent(content[:indent])
      overwritable_lines = format_overwritable_texts(content, indent)
      lines[line_index] = overwritable_lines
      puts overwritable_lines
    end

    def make_indent(indent)
      "  " * indent
    end

    def middle_indent(indent)
      "  " * (indent + 1)
    end

    def format_overwritable_texts(content, indent)
      text_lines = content[:text].split("\n").map { |line| "#{indent}\"#{line}\"" }
      required_lines = content[:end_line] - content[:start_line] + 1 - 2

      middle_indent = middle_indent(content[:indent])
      text_lines << "#{middle_indent}\"\"" while text_lines.size < required_lines

      merged_text = "#{indent}description: [\n#{text_lines.join("\n")}\n#{indent}]"
    end
  end
end
