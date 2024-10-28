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

          file_name = extract_file_name(entry.name)
          return entry if locale_file_format?(file_name, country_name)
        end
      end

      def extract_file_name(file)
        file.split("/").last
      end

      def locale_file_format?(file_name, country_name)
        country_code = to_country_code(country_name)
        file_name.include?("_#{country_code}.json")
      end

      def to_country_code(country_name)
        ISO3166::Country.find_country_by_any_name(country_name).alpha2.downcase
      end
    end
  end
end
