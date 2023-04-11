require "active_support"
require "active_support/time"
Time.zone = "Europe/London"

Dir.glob(File.join(__dir__, "ask_export/**/*.rb")).sort.each { |file| require file }

module AskExport
  CONFIG = {
    draft: {
      survey_id: 849_813,
      region_field_id: 12_861_884,
      question_field_id: 12_861_887,
      share_video_field_id: 12_861_888,
      name_field_id: 12_861_883,
      email_field_id: 12_861_886,
      phone_field_id: 12_861_885,
    },
    live: {
      survey_id: 845_945,
      region_field_id: 12_808_286,
      question_field_id: 12_808_290,
      share_video_field_id: 12_808_730,
      name_field_id: 12_808_285,
      email_field_id: 12_808_288,
      phone_field_id: 12_808_287,
    },
  }.freeze

  def self.config(item)
    environment = ENV.fetch("SMART_SURVEY_CONFIG", "draft").to_sym
    CONFIG[environment].fetch(item)
  end
end
