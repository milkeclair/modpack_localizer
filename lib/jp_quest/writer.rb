require_relative "formatter"
require_relative "indent_helper"

module JpQuest
  class Writer
    include IndentHelper

    # @param [String] file_path ファイルのパス
    # @return [JpQuest::Writer]
    def initialize(file_path)
      @input_file_path = file_path
      @output_file_path = file_path.gsub("quests", "output/quests")
      @formatter = JpQuest::Formatter.new
    end

    # 翻訳された内容でoutput_file_pathを上書きする
    #
    # @param [Hash] translated_contents 翻訳された内容
    # @return [void]
    def overwrites(translated_contents)
      # ディレクトリが存在しない場合は作成
      FileUtils.mkdir_p(File.dirname(@output_file_path))

      # 一度上書きしている場合は上書き後のファイルを読み込む
      # 常に上書き前のファイルを読み込むと、前回の上書きが消えてしまう
      lines = File.readlines(first_overwrite? ? @input_file_path : @output_file_path)
      formatted_lines = overwrite_lines(lines, translated_contents)

      File.open(@output_file_path, "w") do |file|
        file.puts formatted_lines
      end
    end

    private

    # 行を上書きする
    #
    # @param [Array<String>] lines 行
    # @param [Hash] content コンテンツ
    # @return [Array<String>] 上書きされた行
    def overwrite_lines(lines, content)
      indent = create_indent(content[:indent])
      overwritable_lines = @formatter.format_overwritable_lines(content, indent)
      lines[content[:start_line]..content[:end_line]] = overwritable_lines.split("\n")
      lines
    end

    # 最初の上書きかどうか
    #
    # @return [Boolean] 最初の上書きかどうか
    def first_overwrite?
      !File.exist?(@output_file_path)
    end
  end
end
