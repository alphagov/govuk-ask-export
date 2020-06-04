RSpec.describe AskExport::BigQueryExport::TablePopulator do
  describe ".call" do
    let(:table) do
      instance_double(Google::Cloud::Bigquery::Table,
                      insert_async: inserter)
    end

    let(:inserter) do
      instance_double(Google::Cloud::Bigquery::Table::AsyncInserter,
                      insert: nil,
                      stop: double(wait!: nil))
    end

    let(:responses) do
      [serialised_survey_response, serialised_survey_response]
    end

    it "inserts responses into the table" do
      described_class.call(table, responses)
      records = responses.map do |response|
        {
          start_time: response[:start_time].iso8601,
          end_time: response[:end_time].iso8601,
          status: response[:status],
          user_agent: response[:user_agent],
          client_id: response[:client_id],
          region: response[:region],
        }
      end

      expect(inserter).to have_received(:insert).with(records)
    end

    it "returns a hash report of records inserted and with errors" do
      result = instance_double(Google::Cloud::Bigquery::Table::AsyncInserter::Result,
                               error?: false,
                               insert_errors: [],
                               insert_count: 100,
                               error_count: 5)

      allow(table).to receive(:insert_async)
        .and_yield(result)
        .and_return(inserter)

      expect(described_class.call(table, responses))
        .to eq(inserted: 100, errors: 5)
    end

    it "raises an error when big query encounters an exception" do
      error = RuntimeError.new
      result = instance_double(Google::Cloud::Bigquery::Table::AsyncInserter::Result,
                               error?: true,
                               error: error)

      allow(table).to receive(:insert_async)
        .and_yield(result)
        .and_return(inserter)

      expect { described_class.call(table, responses) }
        .to raise_error(error)
    end

    it "prints a warning for any insert errors experienced" do
      insert_error = instance_double(
        Google::Cloud::Bigquery::InsertResponse::InsertError,
        errors: [{ "message" => "An insert error occurred" }],
      )

      result = instance_double(Google::Cloud::Bigquery::Table::AsyncInserter::Result,
                               error?: false,
                               insert_errors: [insert_error],
                               insert_count: 100,
                               error_count: 5)

      allow(table).to receive(:insert_async)
        .and_yield(result)
        .and_return(inserter)

      expect { described_class.call(table, responses) }
        .to output("An insert error occurred\n").to_stderr
    end
  end
end
