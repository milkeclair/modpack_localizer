require "zip"
require "json"
require "countries"
require "iso-639"

module JpQuest
  module JAR
    # .jarファイルから言語ファイルの内容とメタデータを抽出するクラス
    class Reader
      # 例: ja_jp
      REGION_CODE_REGEX = /\A[a-z]{2,3}_[a-z]{2,3}\z/
      LangData = Struct.new(:need_translation, :json, :file_name, :region_code, :mod_name)

      # region_codeが渡された場合、languageとcountry_nameは不要
      #
      # @param [String] file_path ファイルのパス
      # @param [String] language 言語
      # @param [String] country_name 国
      # @param [String] region_code 地域コード
      # @return [JpQuest::JAR::Reader]
      def initialize(file_path, language, country_name, region_code)
        @file_path, @language, @country_name = file_path, language, country_name
        @region_code =
          region_code&.downcase || make_region_code(get_language_code(language), get_country_code(country_name))
        # 引数としてregion_codeが渡された時はチェックしない
        # brb(Netherlands)のような、正規表現にマッチしないregion_codeが存在するため(brbはISO 639-3でqbr_NL)
        validate_region_code(@region_code) unless region_code
      end

      # 言語ファイルの内容とメタデータを抽出する
      #
      # @return [LangData] 言語ファイルの内容とメタデータ
      # @raise [JpQuest::InvalidRegionCodeError] region_codeが不正な場合
      def extract_lang_json_and_meta_data
        Zip::File.open(@file_path) do |jar|
          # 対象の言語ファイルが存在する場合は翻訳が必要ない
          target_lang_file = find_lang_json(jar, @region_code)
          if target_lang_file
            return LangData.new(
              false, {}, target_lang_file, nil, extract_mod_name(target_lang_file)
            )
          end

          lang_file = find_lang_json(jar, "en_us")
          raw_json = JSON.parse(lang_file.get_input_stream.read)

          LangData.new(
            true, except_comment(raw_json), lang_file, @region_code, extract_mod_name(lang_file)
          )
        end
      end

      private

      # 地域コードのバリデーション
      #
      # @param [String] region_code 地域コード
      # @return [Boolean]
      def validate_region_code(region_code)
        return if region_code.match(REGION_CODE_REGEX)

        raise JpQuest::InvalidRegionCodeError.new(region_code)
      end

      # .jar内の言語ファイルを取得する
      #
      # @param [Zip::File] opened_jar .jarファイル
      # @param [String] region_code 地域コード
      # @return [Zip::Entry] 言語ファイル
      def find_lang_json(opened_jar, region_code)
        lang_files = opened_jar.glob("**/lang/*.json")

        lang_files.find { |entry| target_locale_file?(entry, region_code) }
      end

      # JSONからコメントを除外する
      #
      # @param [Hash] hash JSONのハッシュ
      # @return [Hash] コメントを除外したハッシュ
      def except_comment(hash)
        hash.except("_comment")
      end

      # 対象の言語ファイルかどうか
      #
      # @param [Zip::Entry] file ファイル
      # @param [String] region_code 地域コード
      # @return [Boolean]
      def target_locale_file?(file, region_code)
        file_name = extract_file_name(file)

        file_name.include?("#{region_code}.json")
      end

      # フルパスからファイル名を抽出する
      #
      # @param [Zip::Entry] file ファイル
      # @return [String] ファイル名
      def extract_file_name(file)
        file.name.split("/").last
      end

      # フルパスからmod名を抽出する
      #
      # @param [Zip::Entry] file ファイル
      # @return [String] mod名
      def extract_mod_name(file)
        file.name.split("/").last(3).first
      end

      # 地域コードを生成する
      #
      # @param [String] lang_code 言語コード
      # @param [String] country_code 国コード
      # @return [String] 地域コード
      def make_region_code(lang_code, country_code)
        "#{lang_code}_#{country_code}"
      end

      # 言語名から言語コードを取得する
      #
      # @param [String] language_name 言語名
      # @return [String] 言語コード
      def get_language_code(language_name)
        result = ISO_639.find_by_english_name(optimize(language_name))
        result&.alpha2&.downcase || result&.alpha3&.downcase
      end

      # 国名から国コードを取得する
      #
      # @param [String] country_name 国名
      # @return [String] 国コード
      def get_country_code(country_name)
        result = ISO3166::Country.find_country_by_any_name(optimize(country_name))
        result&.alpha2&.downcase || result&.alpha3&.downcase
      end

      # ISO関連のgemが受け付けられる形式に変換
      #
      # @param [String] str 文字列
      # @return [String] 変換後の文字列
      def optimize(str)
        str.gsub("_", " ").split.map(&:capitalize).join(" ")
      end
    end
  end
end
