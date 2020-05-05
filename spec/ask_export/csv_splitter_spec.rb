RSpec.describe AskExport::CsvSplitter do
  describe ".call" do
    around do |example|
      expect { example.run }.to output.to_stdout
    end

    around do |example|
      travel_to(Time.zone.parse("2020-05-01 10:00")) { example.run }
    end

    before { allow(File).to receive(:write) }

    let(:export_path) do
      File.join(__dir__, "../support/files/draft_export.csv")
    end

    it "writes files for each partner named with current date" do
      csv_builder = instance_double(AskExport::CsvBuilder,
                                    cabinet_office: "cabinet-office-data",
                                    third_party: "third-party-data")
      allow(AskExport::CsvBuilder).to receive(:new).and_return(csv_builder)

      described_class.call(export_path)

      expect(File).to have_received(:write)
                  .with(File.expand_path("../../output/2020-05-01-cabinet-office.csv", __dir__),
                        csv_builder.cabinet_office,
                        mode: "w")
      expect(File).to have_received(:write)
                  .with(File.expand_path("../../output/2020-05-01-third-party.csv", __dir__),
                        csv_builder.third_party,
                        mode: "w")
    end

    it "calls CsvBuilder with the epected responses" do
      responses_in_export = [presented_survey_response(id: "100100102"),
                             presented_survey_response(id: "100100103")]

      expect(AskExport::CsvBuilder).to receive(:new)
                                   .with(responses_in_export)
                                   .and_call_original
      described_class.call(export_path)
    end
  end
end
