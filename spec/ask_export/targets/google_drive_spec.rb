RSpec.describe AskExport::Targets::GoogleDrive do
  describe "#export" do
    it "makes a call to Google Drive API" do
      stub_drive_authentication
      upload_stub = stub_google_drive_upload("file.csv", "folder-id")

      target = AskExport::Targets::GoogleDrive.new
      ClimateControl.modify FOLDER_ID_PIPELINE_NAME: "folder-id" do
        target.export("pipeline-name", "file.csv", "data")
      end

      expect(upload_stub).to have_been_requested
    end
  end

  describe "#folder_id_from_env" do
    it "returns an folder id" do
      ClimateControl.modify FOLDER_ID_SOME_NAME: "folder-id" do
        folder_id = AskExport::Targets::GoogleDrive.folder_id_from_env("some-name")
        expect(folder_id).to eq("folder-id")
      end
    end
  end
end
