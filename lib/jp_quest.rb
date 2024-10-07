# frozen_string_literal: true

require "ruby-progressbar"
require_relative "jp_quest/version"
require_relative "jp_quest/help"
require_relative "jp_quest/performer"

module JpQuest
  # JpQuest gemについてのヘルプを表示する
  #
  # @return [void]
  def self.help
    JpQuest::Help.help
  end

  # プログレスバーを生成する
  #
  # @param [String] file_path ファイルのパス
  # @param [Integer] total プログレスバーの合計数
  # @return [ProgressBar::Base] プログレスバー
  def self.create_progress_bar(file_path, total)
    # パスの内、カレントディレクトリ配下のパスのみ表示する
    puts "\nFile path: #{file_path.gsub(Dir.pwd, "")}"

    ProgressBar.create(
      title: "Translating...",
      total: total,
      progress_mark: "#",
      format: " %t [%B]",
      length: 80,
      projector: {
        type: "smoothed",
        strength: 0.1
      }
    )
  end
end
