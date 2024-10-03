# frozen_string_literal: true

require "bundler/setup"
Bundler.require
require_relative "lib/jp_quest"

translator = JpTranslatorFromGpt::Translator.new(output_logs: false)
translator.translate_to_jp("Hello, world!")
