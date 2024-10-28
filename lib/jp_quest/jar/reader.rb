require "zip"
require "countries"

module JpQuest
  module Jar
    class Reader
      def initialize(file_path, country_name)
        @file_path = file_path
        @country_name = country_name
      end

      def read
        Zip::File.open(@file_path) do |jar|
          lang = find_lang_json(jar)
          puts lang
        end
      end

      def find_lang_json(opened_jar, country_name = @country_name)
        lang_files = opened_jar.glob("**/lang/*.json")

        lang_files.find { |entry| target_locale_file?(entry, country_name) }
      end

      def target_locale_file?(file, country_name)
        file_name = extract_file_name(file)
        country_code = get_country_code(country_name)

        file_name.include?("_#{country_code}.json")
      end

      def extract_file_name(file)
        file.name.split("/").last
      end

      def get_country_code(country_name)
        ISO3166::Country.find_country_by_any_name(country_name)&.alpha2&.downcase
      end
    end
  end
end
