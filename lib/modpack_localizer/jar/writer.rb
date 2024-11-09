require "zip"

module ModpackLocalizer
  module JAR
    # .jarファイルを翻訳してリソースパックを作成するクラス
    class Writer
      # 1.19.2
      PACK_FORMAT = 9

      # @return [ModpackLocalizer::JAR::Writer]
      def initialize
        @output_path_base = "output/mods/modpack_localizer"
        @output_path = nil
      end

      # リソースパックを作成する
      #
      # @param [ModpackLocalizer::JAR::Reader::LangData] results 言語ファイルの内容とメタデータ
      # @return [void]
      def make_resource_pack(results)
        results.file_name = replace_default_locale_code(results.file_name.name, results.locale_code)
        @output_path = merge_base_path(results.file_name)

        make_file(@output_path, results.json)
        mcmeta_info = mcmeta(PACK_FORMAT, results.locale_code)
        make_file(mcmeta_info[:file_path], mcmeta_info[:meta_data])

        zipping_resource_pack
      end

      # zipにする前に作成したリソースパックを削除する
      # return [void]
      def remove_before_zipping_directory
        FileUtils.rm_rf(@output_path_base)
      end

      private

      # ファイル名のロケールコードを指定のロケールコードに置き換える
      #
      # @param [String] file_name ファイル名
      # @param [String] locale_code ロケールコード
      # @return [String] ロケールコードが置き換わったファイル名
      def replace_default_locale_code(file_name, locale_code)
        file_name.gsub("en_us", locale_code)
      end

      # ファイルの出力先のパスを生成する
      #
      # @param [String] file_name ファイル名
      # @return [String] ファイルの出力先のパス
      def merge_base_path(file_name)
        "#{@output_path_base}/#{file_name}"
      end

      # ファイルを作成する
      #
      # @param [String] path ファイルのパス
      # @param [Hash] data ファイルに書き込むデータ
      # @return [void]
      def make_file(path, data = nil)
        expand_path = File.expand_path(path)
        dir_path = File.dirname(expand_path)

        FileUtils.mkdir_p(dir_path) unless File.directory?(dir_path)

        File.open(expand_path, "w") do |file|
          file.puts(data.nil? ? "" : JSON.pretty_generate(data))
        end
      end

      # rubocop:disable Lint/SymbolConversion
      # pack.mcmetaを作成するための情報
      #
      # @param [Integer] pack_format リソースパックのバージョン
      # @param [String] locale_code ロケールコード
      # @return [Hash] pack.mcmetaの情報
      def mcmeta(pack_format, locale_code)
        meta_data = {
          "pack": {
            "pack_format": pack_format,
            "description": "Localized for #{locale_code} by ModpackLocalizer"
          }
        }

        file_path = "#{@output_path_base}/pack.mcmeta"
        { file_path: file_path, meta_data: meta_data }
      end
      # rubocop:enable Lint/SymbolConversion

      # リソースパックをzipにする
      #
      # @return [void]
      def zipping_resource_pack
        Zip::File.open("#{@output_path_base}.zip", create: true) do |zip|
          extract_inner_files { |file| add_file_to_zip(zip, file) }
        end
      end

      # ディレクトリ内のファイルをzipに追加する
      #
      # @yield [String] file ファイル
      # @return [void]
      def extract_inner_files(&block)
        Dir.glob("#{@output_path_base}/**/*").each do |file|
          block.call(file)
        end
      end

      # ファイルをzipに追加する
      #
      # @param [Zip::File] zip zipファイル
      # @param [String] file ファイル
      # @return [void]
      def add_file_to_zip(zip, file)
        entry_name = file.sub("#{@output_path_base}/", "")
        zip.add(entry_name, file) unless zip.find_entry(entry_name)
      end
    end
  end
end
