module AskExport
  class DriveUploader
    def initialize
      auth = Google::Auth::ServiceAccountCredentials
               .make_creds(scope: "https://www.googleapis.com/auth/drive")
      @drive = Google::Apis::DriveV3::DriveService.new.tap do |drive|
        drive.authorization = auth
      end
    end

    def upload_csv(filename, csv_contents, folder_id)
      drive.create_file({ name: filename, parents: [folder_id] },
                        fields: "id",
                        upload_source: StringIO.new(csv_contents),
                        supports_all_drives: true,
                        content_type: "text/csv")
    end

    def share_file(file_id, recipients)
      drive.batch do |batch|
        recipients.each do |email_address|
          batch.create_permission(
            file_id,
            { type: "user", role: "reader", email_address: email_address },
            supports_all_drives: true,
            send_notification_email: false,
          )
        end
      end
    end

  private

    attr_reader :drive
  end
end
