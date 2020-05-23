module AskExport
  class SurveyResponseFetcher::ResponseSerialiser
    # Consumers of these exports are already accustumed to a particular
    # time formatting, this is retained here so outputs remain consistent
    SMART_SURVEY_TIME_FORMATTING = "%d/%m/%Y %H:%M:%S".freeze

    def self.call(*args)
      new(*args).call
    end

    def initialize(response)
      @response = response
    end

    def call
      {
        id: response[:id],
        client_id: client_id,
        user_agent: response[:user_agent],
        status: response[:status],
        start_time: format_time(response[:date_started]),
        submission_time: format_time(response[:date_ended]),
        region: fetch_choice_answer(:region_field_id),
        question: fetch_value_answer(:question_field_id),
        question_format: fetch_choice_answer(:question_format_field_id),
        name: fetch_value_answer(:name_field_id),
        email: fetch_value_answer(:email_field_id),
        phone: fetch_value_answer(:phone_field_id),
      }
    end

    private_class_method :new

  private

    attr_reader :response

    def client_id
      return unless response[:variables]

      response[:variables].find { |v| v[:label] == "clientID" }
                          .then { |v| v.to_h[:value] }
    end

    def format_time(time)
      Time.zone.iso8601(time).strftime(SMART_SURVEY_TIME_FORMATTING)
    end

    def fetch_value_answer(field_id)
      fetch_answer(field_id).to_h[:value]
    end

    def fetch_choice_answer(field_id)
      fetch_answer(field_id).to_h[:choice_title]
    end

    def fetch_answer(field_id)
      response[:pages].flat_map { |page| page[:questions] }
                      .find { |question| question[:id] == AskExport.config(field_id) }
                      .then { |item| item.to_h[:answers]&.first }
    end
  end
end
