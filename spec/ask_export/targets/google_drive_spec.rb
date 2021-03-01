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

  describe "#cleanup" do
    it "list files and delete files that are 3 months or older" do
      stub_drive_authentication
      files = [
        { id: 1, name: "file-1", createdTime: 4.months.ago.iso8601.to_s },
        { id: 2, name: "file-2", createdTime: 3.months.ago.iso8601.to_s },
        { id: 3, name: "file-3", createdTime: 1.months.ago.iso8601.to_s },
      ]
      stub_google_drive_list_files("folder-id", files)

      stubs = [1, 2].map do |id|
        stub_google_drive_delete_file(id)
      end

      target = AskExport::Targets::GoogleDrive.new
      ClimateControl.modify FOLDER_ID_PIPELINE_NAME: "folder-id" do
        target.cleanup("pipeline-name")
      end

      stubs.each do |stub|
        expect(stub).to have_been_requested
      end
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
