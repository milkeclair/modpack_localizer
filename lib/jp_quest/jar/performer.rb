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
        output_logs: true, except_words: [], language: "japanese", country: "japan", display_help: true
      )
        @translator = JpTranslatorFromGpt::Translator.new(
          output_logs: output_logs,
          except_words: except_words,
          exchange_language: language
        )
        @country_name = country
        @reader, @writer, @progress_bar = nil

        JpQuest.help if display_help
      end

      def perform(file_path)
        file_path = File.expand_path(file_path)
        validate_path(file_path)

        init_reader_and_writer(file_path)
        results = @reader.extract_lang_json_and_meta_data
        init_progress_bar(file_path, results[:json].length)

        if need_translation?(results) ? translate(results) : feedback_unnecessary_translation(results)
      end

      def perform_directory(dir_path: "mods")
        dir_path = File.expand_path(dir_path)
        validate_path(dir_path)

        Dir.glob("#{dir_path}/*.jar").each do |file_path|
          perform(file_path)
        end
      end

      def validate_path(path)
        path = File.expand_path(path)
        raise JpQuest::PathNotFoundError.new(path) unless File.exist?(path)
      end

      def init_reader_and_writer(file_path)
        @reader = JpQuest::JAR::Reader.new(file_path, @country_name)
        @writer = JpQuest::JAR::Writer.new(file_path)
      end

      def init_progress_bar(file_path, length)
        @progress_bar = JpQuest.create_progress_bar(file_path, length)
      end

      def need_translation?(results)
        results[:need_translation]
      end

      def translate(results)
        results[:json].each do |key, value|
          results[:json][key] = @translator.translate(value)
          @progress_bar.increment
        end

        @writer.make_resource_pack(results)
        puts "Completed!"
      end

      def feedback_unnecessary_translation(results)
        @progress_bar.finish
        puts already_has_translated_file_message(results)
      end

      def already_has_translated_file_message(results)
        "#{results[:mod_name].camelize} already has #{@reader.extract_file_name(results[:file_name])} file."
      end
    end
  end
end
