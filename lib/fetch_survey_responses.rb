require "faraday"
require "json"
require "tzinfo"

class FetchSurveyResponses
  SURVEY_ID = 736162
  REGION_FIELD_ID = 11312915
  QUESTION_FIELD_ID = 11288904
  QUESTION_FORMAT_FIELD_ID = 11324295
  NAME_FIELD_ID = 11289065
  EMAIL_FIELD_ID = 11289069
  PHONE_FIELD_ID = 11312922

  def self.call(*args, &block)
    new(*args).call(&block)
  end

  def initialize(since_time, until_time)
    @since_time = since_time
    @until_time = until_time
  end

  def call
    page = 1
    responses = []
    loop do
      response = http_client.get("surveys/#{SURVEY_ID}/responses",
                                 page: page,
                                 page_size: 100,
                                 since: since_time.utc.to_i,
                                 until: until_time.utc.to_i,
                                 sort_by: "date_ended,asc",
                                 include_labels: true,
                                 completed: 1)

      body = JSON.parse(response.body, symbolize_names: true)
      break if body.empty?

      responses += body.map { |entry| present_entry(entry) }
      yield responses.count if block_given?

      # We're rate limited to 180 requests a minute so we need to slow
      # our requests down a bit
      sleep 0.33
      page += 1
    end

    responses
  end

  private_class_method :new

private

  attr_reader :since_time, :until_time

  def http_client
    @http_client ||= Faraday.new(
      "https://api.smartsurvey.io/v1/",
      params: {
        api_token: ENV.fetch('SMART_SURVEY_API_TOKEN'),
        api_token_secret: ENV.fetch('SMART_SURVEY_API_TOKEN_SECRET'),
      },
    ) { |f| f.request(:retry, max: 3, interval: 1) }
  end

  def present_entry(entry)
    timezone = TZInfo::Timezone.get("Europe/London")
    local_time = timezone.to_local(Time.iso8601(entry[:date_ended]))

    {
      id: entry[:id],
      submission_time: local_time.iso8601,
      region: fetch_choice_answer(entry, REGION_FIELD_ID),
      question: fetch_value_answer(entry, QUESTION_FIELD_ID),
      question_format: fetch_choice_answer(entry, QUESTION_FORMAT_FIELD_ID),
      name: fetch_value_answer(entry, NAME_FIELD_ID),
      email: fetch_value_answer(entry, EMAIL_FIELD_ID),
      phone: fetch_value_answer(entry, PHONE_FIELD_ID),
    }
  end

  def fetch_value_answer(entry, field_id)
    fetch_answer(entry, field_id).to_h[:value]
  end

  def fetch_choice_answer(entry, field_id)
    fetch_answer(entry, field_id).to_h[:choice_title]
  end

  def fetch_answer(entry, field_id)
    answer = entry[:pages].flat_map { |page| page[:questions] }
                          .find { |question| question[:id] == field_id }
                          .then { |response| response.to_h[:answers]&.first }
  end
end
