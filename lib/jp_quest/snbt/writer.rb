require_relative "../util/error"
require_relative "../util/indent_helper"
require_relative "formatter"

module JpQuest
  module SNBT
    # 翻訳された内容を整形して出力するクラス
    class Writer
      include IndentHelper

      # @param [String] file_path ファイルのパス
      # @return [JpQuest::SNBT::Writer]
      def initialize(file_path)
        @input_file_path = file_path
        # questsとすると、quests.snbtも変換されてしまうので、quests/とする
        @output_file_path = file_path.gsub("quests/", "output/quests/")
        @formatter = JpQuest::SNBT::Formatter.new
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

        handle_line_count_error(@output_file_path, lines.length)
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

      # 翻訳前と翻訳後の行数が異なる場合はエラーを発生させる
      #
      # @param [String] output_file_path 出力ファイルのパス
      # @param [Integer] before_line_count 翻訳前の行数
      # @return [void]
      def handle_line_count_error(output_file_path, before_line_count)
        after_line_count = File.readlines(output_file_path).length
        return if before_line_count == after_line_count

        raise JpQuest::InvalidLineCountError.new(before_line_count, after_line_count)
      end
    end
  end
end
