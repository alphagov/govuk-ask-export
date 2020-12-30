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
      allow(AskExport::Pipeline).to receive(:load_all).and_return(pipelines)
      allow(File).to receive(:write)
    end

    let(:csv_builder) do
      instance_double(AskExport::CsvBuilder, build_csv: "csv-data")
    end

    let(:pipelines) do
      [
        instance_double(AskExport::Pipeline, name: "cabinet-office", fields: %i[a b], only_completed: true),
        instance_double(AskExport::Pipeline, name: "data-labs", fields: %i[a b], only_completed: true),
      ]
    end

    it "writes files for each partner named with current date" do
      files = described_class.call

      expected_files = {
        "cabinet-office" => {
          path: "../../output/2020-04-30-1000-to-2020-05-01-1000-cabinet-office.csv",
        },
        "data-labs" => {
          path: "../../output/2020-04-30-1000-to-2020-05-01-1000-data-labs.csv",
        },
      }

      expected_files.each do |_name, file|
        file[:path] = File.expand_path(file[:path], __dir__)
        expect(File).to have_received(:write).with(file[:path], "csv-data", mode: "w")
      end

      expect(files).to eq(expected_files)
    end
  end
end
