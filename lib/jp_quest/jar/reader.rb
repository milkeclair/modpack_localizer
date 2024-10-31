require "zip"
require "json"
require "countries"
require "iso-639"

module JpQuest
  module JAR
    class Reader
      LangData = Struct.new(:need_translation, :json, :file_name, :region_code, :mod_name)

      def initialize(file_path, language, country_name)
        @file_path = file_path
        @language = language
        @country_name = country_name
      end

      def extract_lang_json_and_meta_data
        Zip::File.open(@file_path) do |jar|
          region_code = make_region_code(get_language_code(@language), get_country_code(@country_name))
          # 対象の言語ファイルが存在する場合は翻訳が必要ない
          target_lang_file = find_lang_json(jar, region_code)
          if target_lang_file
            return LangData.new(
              false, {}, target_lang_file, nil, extract_mod_name(target_lang_file)
            )
          end

          lang_file = find_lang_json(jar, "en_us")
          raw_json = JSON.parse(lang_file.get_input_stream.read)

          LangData.new(
            true, except_comment(raw_json), lang_file, region_code, extract_mod_name(lang_file)
          )
        end
      end

      def find_lang_json(opened_jar, region_code)
        lang_files = opened_jar.glob("**/lang/*.json")

        lang_files.find { |entry| target_locale_file?(entry, region_code) }
      end

      def except_comment(hash)
        hash.except("_comment")
      end

      def target_locale_file?(file, region_code)
        file_name = extract_file_name(file)

        file_name.include?("#{region_code}.json")
      end

      def extract_file_name(file)
        file.name.split("/").last
      end

      def extract_mod_name(file)
        file.name.split("/").last(3).first
      end

      def make_region_code(lang_code, country_code)
        "#{lang_code}_#{country_code}"
      end

      def get_language_code(language_name)
        result = ISO_639.find_by_english_name(optimize(language_name))
        result.alpha2 || result.alpha3
      end

      def get_country_code(country_name)
        ISO3166::Country.find_country_by_any_name(optimize(country_name))&.alpha2&.downcase
      end

      def optimize(str)
        # ISO関連のgemが受け付けられる形式に変換
        str.gsub("_", " ").split.map(&:capitalize).join(" ")
      end
    end
  end
end
