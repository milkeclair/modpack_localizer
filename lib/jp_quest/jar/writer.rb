require "zip"

module JpQuest
  module JAR
    class Writer
      # 1.19.2
      PACK_FORMAT = 9

      def initialize
        @output_path_base = "output/mods/jpQuest"
        @output_path = nil
      end

      def make_resource_pack(results)
        results.file_name = replace_default_locale_code(results.file_name.name, results.locale_code)
        @output_path = merge_base_path(results.file_name)

        make_file(@output_path, results.json)
        mcmeta_info = mcmeta(PACK_FORMAT, results.locale_code)
        make_file(mcmeta_info[:file_path], mcmeta_info[:meta_data])

        zipping_resource_pack
      end

      def remove_before_zipping_directory
        FileUtils.rm_rf(@output_path_base)
      end

      private

      def replace_default_locale_code(file_name, locale_code)
        file_name.gsub("en_us", locale_code)
      end

      def merge_base_path(file_name)
        "#{@output_path_base}/#{file_name}"
      end

      def make_file(path, data = nil)
        expand_path = File.expand_path(path)
        dir_path = File.dirname(expand_path)

        FileUtils.mkdir_p(dir_path) unless File.directory?(dir_path)

        File.open(expand_path, "w") do |file|
          file.puts(data.nil? ? "" : JSON.pretty_generate(data))
        end
      end

      # rubocop:disable Lint/SymbolConversion
      def mcmeta(pack_format, locale_code)
        meta_data = {
          "pack": {
            "pack_format": pack_format,
            "description": "Localized for #{locale_code} by jpQuest"
          }
        }

        file_path = "#{@output_path_base}/pack.mcmeta"
        { file_path: file_path, meta_data: meta_data }
      end
      # rubocop:enable Lint/SymbolConversion

      def zipping_resource_pack
        Zip::File.open("#{@output_path_base}.zip", create: true) do |zip|
          extract_inner_files { |file| add_file_to_zip(zip, file) }
        end
      end

      def extract_inner_files(&block)
        Dir.glob("#{@output_path_base}/**/*").each do |file|
          block.call(file)
        end
      end

      def add_file_to_zip(zip, file)
        entry_name = file.sub("#{@output_path_base}/", "")
        zip.add(entry_name, file) unless zip.find_entry(entry_name)
      end
    end
  end
end
