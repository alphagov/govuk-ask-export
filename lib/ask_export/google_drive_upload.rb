require "google/apis/drive_v3"
require "googleauth"

module AskExport
  class GoogleDrive
    SCOPE = Google::Apis::DriveV3::AUTH_DRIVE

    def initialize
      @drive_service = Google::Apis::DriveV3::DriveService.new
      @drive_service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(scope: SCOPE)
    end

    def upload_csv(local_filepath, folder_id)
      file = File.open(local_filepath)
      filename = File.basename(local_filepath)

      @drive_service.create_file({ name: filename, parents: [folder_id] },
                                 fields: "id",
                                 upload_source: file,
                                 supports_all_drives: true,
                                 content_type: "text/csv")
    end
  end
end
