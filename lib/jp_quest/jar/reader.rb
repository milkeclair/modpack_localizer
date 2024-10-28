require "zip"
require "countries"

module JpQuest
  module Jar
    Jar = Zip

    class Reader
      def initialize(file_path, country_name)
        @file_path = file_path
        @country_name = country_name
      end

      def read
        Jar::File.open(@file_path) do |jar|
          lang = find_lang_json(jar)
          puts lang
        end
      end

      def find_lang_json(opened_jar, country_name = @country_name)
        opened_jar.each do |entry|
          # langフォルダ以外は探索不要
          next unless entry.name.include?("lang")

          return entry if target_locale_file?(entry, country_name)
        end
      end

      def target_locale_file?(file, country_name)
        file_name = extract_file_name(file)
        country_code = to_country_code(country_name)

        file_name.include?("_#{country_code}.json")
      end

      def extract_file_name(file)
        file.name.split("/").last
      end

      def to_country_code(country_name)
        ISO3166::Country.find_country_by_any_name(country_name).alpha2.downcase
      end
    end
  end
end
