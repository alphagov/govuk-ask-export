RSpec.describe AskExport::BigQueryExport do
  describe ".call" do
    let(:big_query_project) do
      instance_double(Google::Cloud::Bigquery::Project)
    end

    before do
      allow(Google::Cloud::Bigquery).to receive(:new)
                                    .and_return(big_query_project)
    end

    context "when the report is for a single day" do
      around do |example|
        travel_to(Time.zone.parse("2020-05-01 10:00")) { example.run }
      end

      around do |example|
        expect { example.run }.to output.to_stdout
      end

      let(:report) { stubbed_report }
      let(:big_query_table) { instance_double(Google::Cloud::Bigquery::Table) }
      let(:insert_result) do
        {
          inserted: 100,
          errors: 0,
        }
      end

      before do
        allow(described_class::TableCreator).to receive(:call)
                                            .and_return(big_query_table)
        allow(described_class::TablePopulator).to receive(:call)
                                              .and_return(insert_result)
        allow(AskExport::Report).to receive(:new).and_return(report)
      end

      it "creates a Big Query table based on the end date" do
        expect(described_class::TableCreator)
          .to receive(:call)
          .with(big_query_project, Date.new(2020, 5, 1))
        described_class.call
      end

      it "populates the Big Query table" do
        expect(described_class::TablePopulator)
          .to receive(:call)
          .with(big_query_table, report.responses)
        described_class.call
      end

      it "can accept an injected report" do
        described_class.call(report)
        expect(AskExport::Report).not_to have_received(:new)
      end
    end

    context "when the report isn't for a single day 10am to 10am" do
      it "raises an error" do
        ClimateControl.modify(SINCE_TIME: "2020-05-01 10:00",
                              UNTIL_TIME: "2020-05-03 10:00") do
          message = "Can't run a big query export as the report isn't from "\
                    "10am one day until 10am the next"
          expect { described_class.call }.to raise_error(ArgumentError, message)
        end
      end
    end
  end
end
