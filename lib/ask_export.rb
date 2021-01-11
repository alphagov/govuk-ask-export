require "active_support"
require "active_support/time"
Time.zone = "Europe/London"

Dir.glob(File.join(__dir__, "ask_export/**/*.rb")).sort.each { |file| require file }

module AskExport
  CONFIG = {
    draft: {
      survey_id: 741027,
      region_field_id: 11348121,
      question_field_id: 11348119,
      share_video_field_id: 12188285,
      name_field_id: 11348120,
      email_field_id: 11348122,
      phone_field_id: 11348123,
    },
    live: {
      survey_id: 736162,
      region_field_id: 11312915,
      question_field_id: 11288904,
      share_video_field_id: 12188485,
      name_field_id: 11289065,
      email_field_id: 11289069,
      phone_field_id: 11312922,
    },
    live_version_2: {
      survey_id: 845945,
      region_field_id: 12808286,
      question_field_id: 12808290,
      share_video_field_id: 12808730,
      name_field_id: 12808285,
      email_field_id: 12808288,
      phone_field_id: 12808287,
    },
  }.freeze

  def self.config(item)
    environment = ENV.fetch("SMART_SURVEY_CONFIG", "draft").to_sym
    CONFIG[environment].fetch(item)
  end
end
