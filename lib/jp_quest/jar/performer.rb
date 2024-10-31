require "jp_translator_from_gpt"
require "active_support/core_ext/string/inflections"
require_relative "../util/help"
require_relative "../util/error"
require_relative "reader"
require_relative "writer"

module JpQuest
  module JAR
    class Performer
      def initialize(
        output_logs: true, except_words: [], language: "Japanese",
        country: "Japan", region_code: nil, display_help: true
      )
        @translator = JpTranslatorFromGpt::Translator.new(
          output_logs: output_logs,
          except_words: except_words,
          exchange_language: language
        )
        @language, @country_name, @region_code = language, country, region_code
        @reader, @writer, @progress_bar, @loggable = nil

        JpQuest.help if display_help
      end

      def perform(file_path, loggable: true)
        @loggable = loggable
        file_path = File.expand_path(file_path)
        validate_path(file_path)

        init_reader_and_writer(file_path)
        lang_data = @reader.extract_lang_json_and_meta_data
        init_progress_bar(file_path, lang_data.json.length) if @loggable

        need_translation?(lang_data) ? translate(lang_data) : feedback_unnecessary_translation(lang_data)
      end

      def perform_directory(dir_path: "mods", loggable: true)
        puts "Performing directory: #{dir_path}" unless loggable
        dir_path = File.expand_path(dir_path)
        validate_path(dir_path)

        Dir.glob("#{dir_path}/*.jar").each do |file_path|
          perform(file_path, loggable: loggable)
        end
      end

      def validate_path(path)
        path = File.expand_path(path)
        raise JpQuest::PathNotFoundError.new(path) unless File.exist?(path)
      end

      def init_reader_and_writer(file_path)
        @reader = JpQuest::JAR::Reader.new(file_path, @language, @country_name, @region_code)
        @writer = JpQuest::JAR::Writer.new
      end

      def init_progress_bar(file_path, length)
        @progress_bar = JpQuest.create_progress_bar(file_path, length)
      end

      def need_translation?(lang_data)
        lang_data.need_translation
      end

      def translate(lang_data)
        lang_data.json.each do |key, value|
          # lang_data.json[key] = @translator.translate(value)
          @progress_bar.increment if @loggable
        end

        @writer.make_resource_pack(lang_data)
        puts "Completed!"
      end

      def feedback_unnecessary_translation(lang_data)
        @progress_bar.finish if @loggable
        puts already_has_translated_file_message(lang_data)
      end

      def already_has_translated_file_message(lang_data)
        "#{lang_data.mod_name.camelize} already has #{@reader.extract_file_name(lang_data.file_name)} file."
      end
    end
  end
end
