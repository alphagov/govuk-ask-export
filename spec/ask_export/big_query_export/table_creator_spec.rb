RSpec.describe AskExport::BigQueryExport::TableCreator do
  describe ".call" do
    let(:date) { Date.new(2020, 6, 4) }
    let(:big_query) do
      instance_double(Google::Cloud::Bigquery::Project, dataset: dataset)
    end

    let(:dataset) do
      instance_double(Google::Cloud::Bigquery::Dataset,
                      table: existing_table,
                      create_table: nil)
    end

    let(:existing_table) do
      instance_double(Google::Cloud::Bigquery::Table,
                      exists?: false,
                      delete: nil)
    end

    it "creates a table named based on the date" do
      described_class.call(big_query, date)
      expect(dataset).to have_received(:create_table)
                     .with("all_started_submissions_20200604")
    end

    it "sets the schema for the table" do
      schema = instance_double(Google::Cloud::Bigquery::Schema,
                               timestamp: nil,
                               string: nil)
      allow(dataset).to receive(:create_table).and_yield(schema)
      described_class.call(big_query, date)
      expect(schema).to have_received(:timestamp).twice
      expect(schema).to have_received(:string).exactly(4).times
    end

    it "deletes the table if it already exists" do
      allow(existing_table).to receive(:exists?).and_return(true)
      described_class.call(big_query, date)
      expect(existing_table).to have_received(:delete)
    end
  end
end
