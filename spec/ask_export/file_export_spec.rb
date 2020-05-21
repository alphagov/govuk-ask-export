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
      described_class.call

      {
        "cabinet-office" => csv_builder.cabinet_office,
        "data-labs" => csv_builder.data_labs,
        "performance-analyst" => csv_builder.performance_analyst,
        "third-party" => csv_builder.third_party,
      }.each do |filename_suffix, data|
        expected_file = "../../output/2020-04-30-1000-to-2020-05-01-1000-#{filename_suffix}.csv"
        expect(File)
          .to have_received(:write)
          .with(File.expand_path(expected_file, __dir__),
                data,
                mode: "w")
      end
    end
  end
end
