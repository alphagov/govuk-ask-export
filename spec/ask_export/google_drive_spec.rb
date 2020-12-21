require "tempfile"

RSpec.describe AskExport::GoogleDrive do
  describe "uploading a csv" do
    it "makes a call to Google Drive API" do
      Tempfile.create(["test", ".csv"]) do |file|
        stub_drive_authentication
        upload_stub = stub_google_drive_upload(File.basename(file), "folder-id")

        drive = AskExport::GoogleDrive.new
        drive.upload_csv(file.path, "folder-id")

        expect(upload_stub).to have_been_requested
      end
    end
  end
end
