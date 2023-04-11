require "smart_survey/client"

module AskExport
  class ReportBuilder
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
        survey_id = AskExport.config(:survey_id)
        raw_responses = SmartSurvey::Client.new.list_responses(
          survey_id:,
          response_class: AskExport::Response,
          since_time:,
          until_time:,
        )

        post_process(raw_responses)
      end
    end

    def completed_responses
      responses.select(&:completed?)
    end

    def build(only_completed)
      selected_responses = only_completed ? completed_responses : responses

      Report.new(selected_responses, since_time, until_time)
    end

  private

    def post_process(raw_responses)
      # Pull out all the questions to remove PII
      questions = raw_responses.map(&:question)
      deidentified_questions = Deidentifier.new.bulk_deidentify(questions)

      # Replace question with deidentified version
      raw_responses.each.with_index do |response, index|
        response.question = deidentified_questions[index]
      end

      raw_responses
    end

    def parse_time(time, relative_to:)
      Time.zone.parse(time, relative_to).tap do |parsed|
        message = %("#{time}" could not be parsed as a time)
        raise ArgumentError, message unless parsed
      end
    end
  end
end
