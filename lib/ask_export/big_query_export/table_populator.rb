module AskExport
  class BigQueryExport::TablePopulator
    def self.call(*args)
      new(*args).call
    end

    def initialize(table, responses)
      @table = table
      @responses = responses
    end

    def call
      results = []
      inserter = table.insert_async do |result|
        raise result.error if result.error?

        results << result
        result.insert_errors.each do |error|
          error.errors.each { |e| warn e["message"] }
        end
      end

      inserter.insert(rows)
      inserter.stop.wait!
      completion_report(results)
    end

  private

    attr_reader :table, :responses

    def rows
      responses.map do |response|
        {
          start_time: response[:start_time].iso8601,
          end_time: response[:end_time].iso8601,
          status: response[:status],
          user_agent: response[:user_agent],
          client_id: response[:client_id],
          region: response[:region],
        }
      end
    end

    def completion_report(results)
      {
        inserted: results.sum(&:insert_count),
        errors: results.sum(&:error_count),
      }
    end
  end
end
