RSpec.describe AskExport::FileExport do
  describe ".call" do
    around do |example|
      travel_to(Time.zone.parse("2020-05-01 10:00")) { example.run }
    end

    around do |example|
      expect { example.run }.to output.to_stdout
    end

    before do
      allow(AskExport::Report).to receive(:new).and_return(stubbed_report)
      allow(AskExport::CsvBuilder).to receive(:new).and_return(csv_builder)
      allow(File).to receive(:write)
    end

    let(:csv_builder) do
      instance_double(AskExport::CsvBuilder,
                      cabinet_office: "cabinet-office-data",
                      data_labs: "data-labs-data",
                      performance_analyst: "performance-analyst-data",
                      third_party: "third-party-data")
    end

    it "writes files for each partner named with current date" do
      files = described_class.call

      expected_files = {
        "cabinet-office" => {
          data: csv_builder.cabinet_office,
          path: "../../output/2020-04-30-1000-to-2020-05-01-1000-cabinet-office.csv",
        },
        "data-labs" => {
          data: csv_builder.data_labs,
          path: "../../output/2020-04-30-1000-to-2020-05-01-1000-data-labs.csv",
        },
        "performance-analyst" => {
          data: csv_builder.performance_analyst,
          path: "../../output/2020-04-30-1000-to-2020-05-01-1000-performance-analyst.csv",
        },
        "third-party" => {
          data: csv_builder.third_party,
          path: "../../output/2020-04-30-1000-to-2020-05-01-1000-third-party.csv",
        },
      }

      expected_files.each do |_name, file|
        file[:path] = File.expand_path(file[:path], __dir__)
        expect(File).to have_received(:write).with(file[:path], file[:data], mode: "w")
      end

      expect(files).to eq(expected_files)
    end
  end
end
