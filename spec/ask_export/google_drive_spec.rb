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

  describe "getting the folder id from an env var" do
    it "returns an folder id" do
      ClimateControl.modify FOLDER_ID_SOME_NAME: "folder-id" do
        folder_id = AskExport::GoogleDrive.folder_id_from_env("some-name")
        expect(folder_id).to eq("folder-id")
      end
    end
  end
end
