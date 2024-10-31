module JpQuest
  module JAR
    class Writer
      def initialize
        @output_path_base = "output/mods/jpQuest-#{Time.now.strftime("%Y-%m-%d")}"
        @output_path = nil
      end

      def make_resource_pack(results)
        results.file_name = results.file_name.name.gsub("en_us", results.region_code)
        @output_path = "#{@output_path_base}/#{results.file_name}"
        puts @output_path
      end
    end
  end
end
