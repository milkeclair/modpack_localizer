require "zip"
require "json"
require "countries"
require "iso-639"

module JpQuest
  module JAR
    class Reader
      LangData = Struct.new(:need_translation, :json, :file_name, :mod_name)

      def initialize(file_path, language, country_name)
        @file_path = file_path
        @language = language
        @country_name = country_name
      end

      def extract_lang_json_and_meta_data
        Zip::File.open(@file_path) do |jar|
          # 対象の言語ファイルが存在する場合は翻訳が必要ない
          target_lang_file = find_lang_json(jar)
          return LangData.new(false, {}, target_lang_file, extract_mod_name(target_lang_file)) if target_lang_file

          lang_file = find_lang_json(jar, "English", "United States")
          raw_json = JSON.parse(lang_file.get_input_stream.read)

          LangData.new(true, except_comment(raw_json), lang_file, extract_mod_name(lang_file))
        end
      end

      def find_lang_json(opened_jar, language = @language, country_name = @country_name)
        lang_files = opened_jar.glob("**/lang/*.json")

        lang_files.find { |entry| target_locale_file?(entry, language, country_name) }
      end

      def except_comment(hash)
        hash.except("_comment")
      end

      def target_locale_file?(file, language, country_name)
        file_name = extract_file_name(file)
        lang_code = get_language_code(language)
        country_code = get_country_code(country_name)

        file_name.include?("#{lang_code}_#{country_code}.json")
      end

      def extract_file_name(file)
        file.name.split("/").last
      end

      def extract_mod_name(file)
        file.name.split("/").last(3).first
      end

      def get_language_code(language_name)
        # find_by_english_nameがcase sensitiveの可能性があるので念のため
        language_name = language_name.split.map(&:capitalize).join(" ")
        result = ISO_639.find_by_english_name(language_name)
        result.alpha2 || result.alpha3
      end

      def get_country_code(country_name)
        # find_country_by_any_nameがcase sensitiveの可能性があるので念のため
        country_name = country_name.split.map(&:capitalize).join(" ")
        ISO3166::Country.find_country_by_any_name(country_name)&.alpha2&.downcase
      end
    end
  end
end
