require "active_support"
require "active_support/time"
Time.zone = "Europe/London"

require_relative "ask_export/csv_builder"
require_relative "ask_export/csv_splitter"
require_relative "ask_export/runner"
require_relative "ask_export/survey_response_fetcher"

module AskExport
  CONFIG = {
    draft: {
      survey_id: 741027,
      region_field_id: 11348121,
      question_field_id: 11348119,
      question_format_field_id: 11348124,
      name_field_id: 11348120,
      email_field_id: 11348122,
      phone_field_id: 11348123,
    },
    live: {
      survey_id: 736162,
      region_field_id: 11312915,
      question_field_id: 11288904,
      question_format_field_id: 11324295,
      name_field_id: 11289065,
      email_field_id: 11289069,
      phone_field_id: 11312922,
    },
  }.freeze

  def self.config(item)
    environment = ENV["SMART_SURVEY_LIVE"] == "true" ? :live : :draft
    CONFIG[environment].fetch(item)
  end
end
