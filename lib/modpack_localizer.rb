# frozen_string_literal: true

require "ruby-progressbar"
require_relative "modpack_localizer/util/version"
require_relative "modpack_localizer/util/help"
require_relative "modpack_localizer/snbt/performer"
require_relative "modpack_localizer/jar/performer"

# SNBT形式のファイルを翻訳する
# 翻訳できるプロパティ
# - title
# - subtitle
# - description
module ModpackLocalizer
  # quests, mods配下のファイルを全て翻訳する
  # locale_codeを指定する場合、countryの指定は不要
  #
  # @param [String] language 言語
  # @param [String] country 国
  # @param [String] locale_code ロケールコード(例: "ja_jp")
  # @param [Boolean] threadable quests, modsの翻訳を並列で行うか
  # @return [void]
  def self.omakase(language: "Japanese", country: "Japan", locale_code: nil, threadable: false)
    performers = [] << ModpackLocalizer::SNBT::Performer.new(language:)
    performers << ModpackLocalizer::JAR::Performer.new(
      language:, country:, locale_code:, display_help: false
    )

    if threadable
      threads = performers.map { Thread.new { it.perform_directory(loggable: false) } }
      threads.each(&:join)
    else
      performers.each(&:perform_directory)
    end
  end

  # ModpackLocalizer gemについてのヘルプを表示する
  #
  # @return [void]
  def self.help
    ModpackLocalizer::Help.help
  end

  # プログレスバーを生成する
  #
  # @param [String] file_path ファイルのパス
  # @param [Integer] total プログレスバーの合計数
  # @return [ProgressBar::Base] プログレスバー
  def self.create_progress_bar(file_path, total)
    # パスの内、カレントディレクトリ配下のパス以外は邪魔なので削除
    # 例: /Users/user/quests/some.snbt -> /quests/some.snbt
    puts "\nFile path: #{file_path.gsub(Dir.pwd, "")}"

    ProgressBar.create(
      title: "Translating...",
      total: total,
      progress_mark: "#",
      format: "%t [%B]",
      length: 80,
      projector: {
        type: "smoothed",
        strength: 0.1
      }
    )
  end
end
