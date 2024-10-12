require "jp_quest"

performer = JpQuest::SNBT::Performer.new

# file_path = "some.snbt"
# performer.perform(file_path)

performer.perform_directory
