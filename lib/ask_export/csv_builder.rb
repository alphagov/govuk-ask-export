require "csv"

module AskExport
  class CsvBuilder
    # Consumers of these exports are already accustumed to a particular
    # time formatting, this is retained here so outputs remain consistent
    SMART_SURVEY_TIME_FORMATTING = "%d/%m/%Y %H:%M:%S".freeze

    def initialize(report)
      @report = report
    end

    def cabinet_office
      build_csv(report.completed_responses,
                :id,
                :submission_time,
                :region,
                :name,
                :email,
                :phone)
    end

    def data_labs
      responses = report.completed_responses.map do |response|
        response.merge(hashed_email: hash(response[:email]),
                       hashed_phone: hash(response[:phone]))
      end

      build_csv(responses,
                :submission_time,
                :region,
                :question,
                :hashed_email,
                :hashed_phone)
    end

    def performance_analyst
      build_csv(report.responses,
                :start_time,
                :submission_time,
                :status,
                :user_agent,
                :client_id,
                :region)
    end

    def third_party
      build_csv(report.completed_responses,
                :id,
                :submission_time,
                :region,
                :question)
    end

  private

    attr_reader :report

    def build_csv(responses, *fields)
      CSV.generate do |csv|
        csv << fields
        responses.each { |response| csv << csv_row(response, fields) }
      end
    end

    def csv_row(response, fields)
      row = response.merge(
        start_time: response[:start_time].strftime(SMART_SURVEY_TIME_FORMATTING),
        submission_time: response[:end_time].strftime(SMART_SURVEY_TIME_FORMATTING),
      )
      row.slice(*fields).values
    end

    def hash(field)
      Digest::SHA256.hexdigest(field + ENV.fetch("SECRET_KEY"))
    end
  end
end
