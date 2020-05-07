require "csv"

module AskExport
  class CsvBuilder
    def initialize(daily_report)
      @daily_report = daily_report
    end

    def cabinet_office
      build_csv(:id,
                :submission_time,
                :region,
                :name,
                :email,
                :phone,
                :question_format)
    end

    def third_party
      build_csv(:id,
                :submission_time,
                :region,
                :question,
                :question_format)
    end

  private

    attr_reader :daily_report

    def build_csv(*fields)
      CSV.generate do |csv|
        csv << fields
        daily_report.responses.each { |row| csv << row.slice(*fields).values }
      end
    end
  end
end
