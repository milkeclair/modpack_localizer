require "jp_translator_from_gpt"
require_relative "../util/help"
require_relative "../util/error"
require_relative "reader"

module JpQuest
  module Jar
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
        @reader = nil
        @writer = nil
        @progress_bar = nil

        JpQuest.help if display_help
      end

      def perform(file_path)
        file_path = File.expand_path(file_path)
        validate_path(file_path)

        @reader, @writer = JpQuest::Jar::Reader.new(file_path, @country_name), JpQuest::Jar::Writer.new(file_path)
        results = @reader.extract
        @progress_bar = JpQuest.create_progress_bar(file_path, results.length)

        if need_translation?(results)
          results[:json] = translate(results[:json])
          @writer.write_resource_pack(results)
          puts "Completed!"
        else
          @progress_bar.finish
          puts "No translation required"
        end
      end

      def perform_directory(dir_path: "mods")
        dir_path = File.expand_path(dir_path)
        validate_path(dir_path)

        Dir.glob("#{dir_path}/**/*.jar").each do |file_path|
          perform(file_path)
        end
      end

      def validate_path(path)
        path = File.expand_path(path)
        raise JpQuest::PathNotFoundError.new(path) unless File.exist?(path)
      end

      def need_translation?(results)
        results[:need_translation]
      end

      def translate(json)
        json.each do |key, value|
          json[key] = @translator.translate(value)
          @progress_bar.increment
        end
        json
      end
    end
  end
end
