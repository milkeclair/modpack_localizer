require "modpack_localizer"

# ModpackLocalizer.omakase(language: "English")
# or
begin
  ModpackLocalizer.omakase
rescue StandardError => e
  puts e
  puts e.backtrace
end
