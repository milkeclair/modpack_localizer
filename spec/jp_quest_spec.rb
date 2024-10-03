# frozen_string_literal: true

RSpec.describe JpQuest do
  it "バージョンが存在すること" do
    expect(JpQuest::VERSION).not_to be nil
  end
end
