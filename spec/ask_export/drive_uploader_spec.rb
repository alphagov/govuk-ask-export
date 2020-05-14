RSpec.describe AskExport::DriveUploader do
  before do
    allow(Google::Auth::ServiceAccountCredentials).to receive(:make_creds)
                                                  .and_return("secret credentials")
    allow(Google::Apis::DriveV3::DriveService).to receive(:new)
                                              .and_return(drive)
  end

  let(:drive) do
    drive = instance_double(Google::Apis::DriveV3::DriveService,
                            "authorization=": nil,
                            create_file: nil,
                            create_permission: nil)
    allow(drive).to receive(:batch).and_yield(drive)
    drive
  end

  describe "#upload_csv" do
    it "creates a CSV on google drive in the specified folder" do
      described_class.new.upload_csv("my-file.csv", "1,2,3\n", "my-folder")
      expect(drive)
        .to have_received(:create_file)
        .with({ name: "my-file.csv", parents: %w[my-folder] },
              a_hash_including(content_type: "text/csv",
                               supports_all_drives: true,
                               upload_source: an_instance_of(StringIO)))
    end
  end

  describe "#share_file" do
    it "sends a batch request setting reader permissions for each recipient" do
      described_class.new.share_file("file-id",
                                     %w[1@example.com 2@example.com])
      expect(drive).to have_received(:batch)
      expect(drive)
        .to have_received(:create_permission)
        .with("file-id",
              a_hash_including(type: "user",
                               role: "reader",
                               email_address: /@example\.com/),
              supports_all_drives: true,
              send_notification_email: false)
        .twice
    end
  end
end
