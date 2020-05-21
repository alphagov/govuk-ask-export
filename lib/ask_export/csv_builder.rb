require "csv"

module AskExport
  class CsvBuilder
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
                :phone,
                :question_format)
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
                :question_format,
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
                :question,
                :question_format)
    end

  private

    attr_reader :report

    def build_csv(responses, *fields)
      CSV.generate do |csv|
        csv << fields
        responses.each { |row| csv << row.slice(*fields).values }
      end
    end

    def hash(field)
      Digest::SHA256.hexdigest(field + ENV.fetch("SECRET_KEY"))
    end
  end
end
