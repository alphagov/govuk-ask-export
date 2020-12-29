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
      build_csv(report.completed_responses,
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
        responses.each do |response|
          csv << fields.map { |field| response[field] }
        end
      end
    end
  end
end
