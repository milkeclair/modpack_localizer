require "zip"
require "countries"

module JpQuest
  module Jar
    class Reader
      def initialize(file_path, country)
        @file_path = file_path
        @country = country
      end

      def read
        Zip::File.open(@file_path) do |zip_file|
          lang = find_lang_json(zip_file)
          puts lang
        end
      end

      def find_lang_json(zip_file, country = @country)
        zip_file.each do |entry|
          # langフォルダ以外は探索不要
          next unless entry.name.include?("lang")

          country_code = to_country_code(country)
          file_name = extract_file_name(entry.name)

          return entry if file_name.include?("_#{country_code}.json")
        end
      end

      def to_country_code(country)
        ISO3166::Country.find_country_by_any_name(country).alpha2.downcase
      end

      def extract_file_name(file)
        file.split("/").last
      end
    end
  end
end
