require "rainbow"

module JpQuest
  # ヘルプを表示する
  #
  # @return [void]
  def self.help
    puts <<~HELP
      #{cyan("=== JpQuest Help ===================================================================").bold}\n
      #{help_warning}
      #{help_intro}
      #{help_steps}
      #{help_init_options}
      #{help_information}
      #{cyan("====================================================================================").bold}
    HELP
  end

  def self.help_warning
    <<~WARNING
      #{red("Warning:").bold} Please be careful your OpenAI API usage cost.
    WARNING
  end

  def self.help_intro
    <<~INTRO
      #{cyan("Introduction:").bold}
        Translator for #{green(".snbt")} files.
        If you want to translate to other languages than Japanese,
        please add the #{green("exchange_language")} option during initialization.
        Example: #{green("JpQuest::Performer.new(exchange_language: \"English\")")}
    INTRO
  end

  def self.help_steps
    <<~STEPS
      #{cyan("Steps:").bold}
        1. exec #{green("touch .env")} bash command
        2. Add #{green("OPENAI_API_KEY=your_api_key")} to .env
        3. Optional: Add #{green("OPENAI_MODEL=some_openai_model")} to .env (default: gpt-4o-mini)
        4. Add "quests" directory to your project
        5. Add #{green("require \"jp_quest\"")}
        6. exec #{green("bundle install")} bash command
        7. Add #{green("jp_quest = JpQuest::Performer.new")}
        8. #{green("jp_quest.perform(\"file_path\")")} or
           #{green("jp_quest.perform_directly(dir_path: \"dir_path\")")}
        9. Check "quests/output" directory
    STEPS
  end

  def self.help_init_options
    <<~OPTIONS
      #{cyan("Initialize Options:").bold}
        output_logs:
          Want to output OpenAI usage logs?
          (default: true)
        except_words:
          Words that you don't want to translate
          (default: empty array)
        exchange_language:
          Which language do you want to translate to?
          (default: japanese)
        display_help:
          Want to display help?
          (default: false)
    OPTIONS
  end

  def self.help_information
    <<~INFORMATION
      #{cyan("Information:").bold}
        jp_quest:
          #{link("https://github.com/milkeclair/jp_quest")}
          current version: #{JpQuest::VERSION}
        translator:
          #{link("https://github.com/milkeclair/jp_translator_from_gpt")}
          current version: #{JpTranslatorFromGpt::VERSION}
    INFORMATION
  end

  def self.cyan(str)
    Rainbow(str).cyan
  end

  def self.green(str)
    Rainbow(str).green
  end

  def self.red(str)
    Rainbow(str).red
  end

  def self.link(str)
    Rainbow(str).underline.bright
  end
end
