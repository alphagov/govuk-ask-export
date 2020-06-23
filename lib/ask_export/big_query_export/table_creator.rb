module AskExport
  class BigQueryExport::TableCreator
    def self.call(*args)
      new(*args).call
    end

    def initialize(big_query, date)
      @big_query = big_query
      @date = date
    end

    def call
      existing_table = dataset.table(table_name, skip_lookup: true)
      existing_table.delete if existing_table.exists?

      dataset.create_table(table_name) do |schema|
        schema.timestamp("start_time", mode: :required)
        schema.timestamp("end_time", mode: :required)
        schema.string("status", mode: :required)
        schema.string("user_agent", mode: :required)
        schema.string("client_id")
        schema.string("region")
      end
    end

  private

    attr_reader :big_query, :date

    def dataset
      @dataset ||= begin
        dataset_name = AskExport.config(:big_query_dataset)
        big_query.dataset(dataset_name) || raise("Dataset #{dataset_name} doesn't appear to exist")
      end
    end

    def table_name
      "all_started_submissions_#{date.strftime('%Y%m%d')}"
    end
  end
end
