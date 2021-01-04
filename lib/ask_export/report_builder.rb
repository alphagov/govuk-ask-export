module AskExport
  class ReportBuilder
    SMART_SURVEY_TIME_FORMATTING = "%d/%m/%Y %H:%M:%S".freeze

    def since_time
      @since_time ||= parse_time(ENV.fetch("SINCE_TIME", "10:00"),
                                 relative_to: Date.yesterday)
    end

    def until_time
      @until_time ||= parse_time(ENV.fetch("UNTIL_TIME", "10:00"),
                                 relative_to: Date.current)
    end

    def responses
      @responses ||= begin
        SurveyResponseFetcher.call(since_time, until_time).map do |response|
          add_computed_fields(response)
        end
      end
    end

    def completed_responses
      responses.select { |r| r[:status] == "completed" }
    end

    def build(only_completed)
      selected_responses = only_completed ? completed_responses : responses

      Report.new(selected_responses, since_time, until_time)
    end

  private

    def add_computed_fields(response)
      computed_fields = {}
      computed_fields[:hashed_phone] = hash(response[:phone]) if response[:phone]
      computed_fields[:hashed_email] = hash(response[:email]) if response[:email]
      computed_fields[:start_time] = response[:start_time].strftime(SMART_SURVEY_TIME_FORMATTING)
      computed_fields[:submission_time] = response[:end_time].strftime(SMART_SURVEY_TIME_FORMATTING)

      response.merge(computed_fields)
    end

    def hash(field)
      Digest::SHA256.hexdigest(field + ENV.fetch("SECRET_KEY"))
    end

    def parse_time(time, relative_to:)
      Time.zone.parse(time, relative_to).tap do |parsed|
        message = %("#{time}" could not be parsed as a time)
        raise ArgumentError, message unless parsed
      end
    end
  end
end
