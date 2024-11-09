module JpQuest
  module JAR
    class Writer
      def initialize
        @output_path_base = "output/mods/jpQuest-#{Time.now.strftime("%Y-%m-%d")}"
        @output_path = nil
      end

      def make_resource_pack(results)
        results.file_name = replace_default_locale_code(results.file_name.name, results.locale_code)
        @output_path = merge_base_path(results.file_name)
        make_file(@output_path)
      end

      private

      def replace_default_locale_code(file_name, locale_code)
        file_name.gsub("en_us", locale_code)
      end

      def merge_base_path(file_name)
        "#{@output_path_base}/#{file_name}"
      end

      def make_file(path)
        FileUtils.mkdir_p(path) unless File.exist?(File.expand_path(path))
      end
    end
  end
end
