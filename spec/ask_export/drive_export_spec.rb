RSpec.describe AskExport::DriveExport do
  describe ".call" do
    around do |example|
      travel_to(Time.zone.parse("2020-05-01 10:00")) { example.run }
    end

    around do |example|
      expect { example.run }.to output.to_stdout
    end

    around do |example|
      ClimateControl.modify(
        CABINET_OFFICE_DRIVE_FOLDER: "cabinet-office-folder-id",
        CABINET_OFFICE_RECIPIENTS: "cabinet-office-1@example.com, cabinet-office-2@example.com",
        DATA_LABS_DRIVE_FOLDER: "data-labs-folder-id",
        DATA_LABS_RECIPIENTS: "data-labs@example.com",
        PERFORMANCE_ANALYST_DRIVE_FOLDER: "performance-analyst-folder-id",
        PERFORMANCE_ANALYST_RECIPIENTS: "performance-analyst@example.com",
        THIRD_PARTY_DRIVE_FOLDER: "third-party-folder-id",
        THIRD_PARTY_RECIPIENTS: "third-party@example.com",
      ) { example.run }
    end

    before do
      allow(AskExport::Report).to receive(:new).and_return(stubbed_report)
      allow(AskExport::CsvBuilder).to receive(:new).and_return(csv_builder)
      allow(AskExport::DriveUploader).to receive(:new).and_return(drive_uploader)
    end

    let(:csv_builder) do
      instance_double(AskExport::CsvBuilder,
                      cabinet_office: "cabinet-office-data",
                      data_labs: "data-labs-data",
                      performance_analyst: "performance-analyst-data",
                      third_party: "third-party-data")
    end

    let(:drive_uploader) do
      instance_double(AskExport::DriveUploader,
                      upload_csv: OpenStruct.new(id: "file-id"),
                      share_file: nil)
    end

    it "uploads and shares a CSV for the Cabinet Office" do
      described_class.call

      expect(drive_uploader).to have_received(:upload_csv)
                            .with("2020-04-30-1000-to-2020-05-01-1000-cabinet-office.csv",
                                  "cabinet-office-data",
                                  "cabinet-office-folder-id")

      expect(drive_uploader).to have_received(:share_file)
                            .with("file-id",
                                  %w[cabinet-office-1@example.com cabinet-office-2@example.com])
    end

    it "uploads and shares a CSV for Data Labs" do
      described_class.call

      expect(drive_uploader).to have_received(:upload_csv)
                            .with("2020-04-30-1000-to-2020-05-01-1000-data-labs.csv",
                                  "data-labs-data",
                                  "data-labs-folder-id")

      expect(drive_uploader).to have_received(:share_file)
                            .with("file-id",
                                  %w[data-labs@example.com])
    end

    it "uploads and shares a CSV for performance analysis" do
      described_class.call

      expect(drive_uploader).to have_received(:upload_csv)
                            .with("2020-04-30-1000-to-2020-05-01-1000-performance-analyst.csv",
                                  "performance-analyst-data",
                                  "performance-analyst-folder-id")

      expect(drive_uploader).to have_received(:share_file)
                            .with("file-id",
                                  %w[performance-analyst@example.com])
    end

    it "uploads and shares a CSV for a Third Party" do
      described_class.call

      expect(drive_uploader).to have_received(:upload_csv)
                            .with("2020-04-30-1000-to-2020-05-01-1000-third-party.csv",
                                  "third-party-data",
                                  "third-party-folder-id")

      expect(drive_uploader).to have_received(:share_file)
                            .with("file-id",
                                  %w[third-party@example.com])
    end
  end
end
