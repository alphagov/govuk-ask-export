module AskExport
  class SurveyResponseFetcher::ResponseSerialiser
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
        status: status,
        start_time: Time.zone.iso8601(response[:date_started]),
        end_time: Time.zone.iso8601(response[:date_ended]),
      }.merge(answers)
    end

    private_class_method :new

  private

    attr_reader :response

    def client_id
      return unless response[:variables]

      response[:variables].find { |v| v[:label] == "clientID" }
                          .then { |v| v.to_h[:value] }
    end

    def status
      return response[:status] unless response[:status] == "completed"

      # We've had situations where an incomplete survey response is returned
      # from Smart Survey with a "completed" status this seems to because
      # Smart Survey enforces required fields only on the client side
      required = %i[region question share_video name email phone]
      nil_fields = required.select { |field| answers[field].nil? }

      if nil_fields.any?
        warn "Response #{response[:id]} has a completed status but has null " \
             "fields: #{nil_fields.join(', ')}"

        "partial"
      else
        "completed"
      end
    end

    def answers
      @answers ||= {
        region: fetch_choice_answer(:region_field_id),
        question: fetch_value_answer(:question_field_id),
        share_video: fetch_choice_answer(:share_video_field_id),
        name: fetch_value_answer(:name_field_id),
        email: fetch_value_answer(:email_field_id),
        phone: fetch_value_answer(:phone_field_id),
      }
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
