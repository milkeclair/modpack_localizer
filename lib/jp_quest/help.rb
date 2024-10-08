require "rainbow"

module JpQuest
  # JpQuest gemについてのヘルプを表示するクラス
  class Help
    # JpQuest gemについてのヘルプを表示する
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

    # 警告
    #
    # @return [String]
    def self.help_warning
      <<~WARNING
        #{red("Warning:").bold} Please be careful your OpenAI API usage cost.
      WARNING
    end

    # gemの説明
    #
    # @return [String]
    def self.help_intro
      <<~INTRO
        #{cyan("Introduction:").bold}
          Translator for #{green(".snbt")} files.
          If you want to translate to other languages than Japanese,
          please add the #{green("exchange_language")} option during initialization.
          Example: #{green("JpQuest::Performer.new(exchange_language: \"English\")")}
      INTRO
    end

    # 使用手順
    #
    # @return [String]
    def self.help_steps
      <<~STEPS
        #{cyan("Steps:").bold}
          1. exec #{green("touch .env")} bash command
          2. Add #{green("OPENAI_API_KEY=your_api_key")} to .env
          3. Optional: Add #{green("OPENAI_MODEL=some_openai_model")} to .env (default: gpt-4o-mini)
          4. Add "quests" directory to your project
          5. #{green("gem install jp_quest")} or #{green("gem \"jp_quest\"")}
          6. Add #{green("require \"jp_quest\"")}
          7. Add #{green("jp_quest = JpQuest::Performer.new")}
          8. #{green("jp_quest.perform(\"file_path\")")} or
             #{green("jp_quest.perform_directly(dir_path: \"dir_path\")")}
          9. Check "output" directory
      STEPS
    end

    # newメソッドのオプション
    #
    # @return [String]
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
            (default: true)
      OPTIONS
    end

    # その他gemに関する情報
    #
    # @return [String]
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

    # 出力を青色にする
    #
    # @param [String] str
    # @return [String]
    def self.cyan(str)
      Rainbow(str).cyan
    end

    # 出力を緑色にする
    #
    # @param [String] str
    # @return [String]
    def self.green(str)
      Rainbow(str).green
    end

    # 出力を赤色にする
    #
    # @param [String] str
    # @return [String]
    def self.red(str)
      Rainbow(str).red
    end

    # 出力をリンクのスタイルにする
    #
    # @param [String] str
    # @return [String]
    def self.link(str)
      Rainbow(str).underline.bright
    end
  end
end
