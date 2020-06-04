require "google/cloud/bigquery"

module AskExport
  class BigQueryExport
    def self.call(*args)
      new(*args).call
    end

    def initialize
      @report = Report.new
      @big_query = Google::Cloud::Bigquery.new(project: "govuk-bigquery-analytics")
    end

    def call
      unless exportable_report?
        raise ArgumentError,
              "Can't run a big query export as the report isn't from 10am one "\
              "day until 10am the next"
      end

      table = TableCreator.call(big_query, report.until_time.to_date)
      result = TablePopulator.call(table, report.responses)
      puts "Inserted #{result[:inserted]} records into BigQuery, " \
           "with #{result[:errors]} errors"
    end

  private

    attr_reader :report, :big_query

    def exportable_report?
      one_day = report.until_time.to_date - 1 == report.since_time.to_date
      ten_until_ten = [report.since_time, report.until_time].map { |t| t.strftime("%H:%M:%S") }
                                                            .all? { |t| t == "10:00:00" }
      one_day && ten_until_ten
    end
  end
end
