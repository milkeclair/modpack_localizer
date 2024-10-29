require "zip"
require "json"
require "countries"

module JpQuest
  module Jar
    class Reader
      def initialize(file_path, country_name)
        @file_path = file_path
        @country_name = country_name
      end

      def extract_lang_json
        Zip::File.open(@file_path) do |jar|
          # 対象の言語ファイルが存在する場合は翻訳が必要ない
          return { need_translation: false } if find_lang_json(jar)

          lang_file = find_lang_json(jar, "united states")
          raw_json = JSON.parse(lang_file.get_input_stream.read)

          { need_translation: true, json: except_comment(raw_json), file_name: lang_file.name }
        end
      end

      def find_lang_json(opened_jar, country_name = @country_name)
        lang_files = opened_jar.glob("**/lang/*.json")

        lang_files.find { |entry| target_locale_file?(entry, country_name) }
      end

      def except_comment(hash)
        hash.except("_comment")
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
