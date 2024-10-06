# frozen_string_literal: true

require_relative "lib/jp_quest"

performer = JpQuest::Performer.new(output_logs: false, display_help: true)
# dir_path = "quests"
file_path = "hoge.snbt"

performer.perform(file_path)
# performer.perform_directly(dir_path: dir_path)
