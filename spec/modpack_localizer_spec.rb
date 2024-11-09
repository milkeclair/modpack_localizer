# frozen_string_literal: true

RSpec.describe ModpackLocalizer do
  it "バージョンが存在すること" do
    expect(ModpackLocalizer::VERSION).not_to be nil
  end
end
