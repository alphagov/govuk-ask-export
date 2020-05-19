RSpec.describe AskExport::FileDistributor do
  around do |example|
    ClimateControl.modify(NOTIFY_API_KEY: "secret") { example.run }
  end

  before do
    allow(Google::Auth::ServiceAccountCredentials).to receive(:make_creds)
                                                  .and_return("secret credentials")
    allow(Google::Apis::DriveV3::DriveService).to receive(:new)
                                              .and_return(drive)
    allow(Notifications::Client).to receive(:new).and_return(notify_client)
  end

  let(:drive) do
    drive = instance_double(Google::Apis::DriveV3::DriveService,
                            "authorization=": nil,
                            create_file: nil,
                            create_permission: nil)
    allow(drive).to receive(:batch).and_yield(drive)
    drive
  end

  let(:notify_client) do
    instance_double(Notifications::Client, send_email: true)
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
    let(:personalisation) { { key: "value" } }

    it "sends a batch request setting reader permissions for each recipient" do
      described_class.new.share_file("file-id",
                                     %w[1@example.com 2@example.com],
                                     personalisation)
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

    it "notifies each recipient they've had the file shared" do
      described_class.new.share_file("file-id",
                                     %w[1@example.com 2@example.com],
                                     personalisation)

      file_url = "https://drive.google.com/file/d/file-id/view"
      expect(notify_client).to have_received(:send_email)
        .with(email_address: "1@example.com",
              template_id: described_class::NOTIFY_TEMPLATE_ID,
              email_reply_to_id: described_class::NOTIFY_REPLY_TO_ID,
              personalisation: personalisation.merge(file_url: file_url))
      expect(notify_client).to have_received(:send_email)
        .with(email_address: "2@example.com",
              template_id: described_class::NOTIFY_TEMPLATE_ID,
              email_reply_to_id: described_class::NOTIFY_REPLY_TO_ID,
              personalisation: personalisation.merge(file_url: file_url))
    end
  end
end
