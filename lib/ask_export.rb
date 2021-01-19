require "active_support"
require "active_support/time"
Time.zone = "Europe/London"

Dir.glob(File.join(__dir__, "ask_export/**/*.rb")).sort.each { |file| require file }

module AskExport
  CONFIG = {
    draft: {
      survey_id: 849813,
      region_field_id: 12861884,
      question_field_id: 12861887,
      share_video_field_id: 12861888,
      name_field_id: 12861883,
      email_field_id: 12861886,
      phone_field_id: 12861885,
    },
    live: {
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
