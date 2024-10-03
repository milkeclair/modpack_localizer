# frozen_string_literal: true

require_relative "lib/jp_quest"

performer = JpQuest::Performer.new(output_logs: false)
performer.perform(".snbt")
