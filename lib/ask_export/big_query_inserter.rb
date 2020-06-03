require "google/cloud/bigquery"

module AskExport
  class BigQueryInserter
    def self.call(*args)
      new(*args).call
    end

    def initialize(report)
      @report = report
      @big_query = Google::Cloud::Bigquery.new
    end

    def call
      inserter = table.insert_async do |result|
        if result.error?
          warn result.error
        else
          puts "inserted #{result.insert_count} rows " \
            "with #{result.error_count} errors"
        end
      end

      inserter.insert(rows)
      inserter.stop.wait!
    end

  private

    attr_reader :report

    def table
      @table ||= begin
                   dataset_name = AskExport.config("big_query_dataset")
                   dataset = bigquery.dataset(dataset_name)
                   dataset.table("all_started_submissions")
                 end
    end

    def rows
      report.responses.map do |response|
        {
          start_time: response[:start_time],
          end_time: response[:end_time],
          response_id: response[:id],
          status: response[:status],
          user_agent: response[:user_agent],
          client_id: response[:client_id],
          region: response[:region],
        }
      end
    end
  end
end
