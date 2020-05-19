require "notifications/client"

module AskExport
  class FileDistributor
    NOTIFY_TEMPLATE_ID = "72d86083-e851-468e-86c6-6d3b2bca27e0".freeze
    NOTIFY_REPLY_TO_ID = "e5b39823-14a6-4a2d-ba0b-8dbf47abb99f".freeze

    def initialize
      auth = Google::Auth::ServiceAccountCredentials
               .make_creds(scope: "https://www.googleapis.com/auth/drive")
      @drive = Google::Apis::DriveV3::DriveService.new.tap do |drive|
        drive.authorization = auth
      end
      @notify_client = Notifications::Client.new(ENV.fetch("NOTIFY_API_KEY"))
    end

    def upload_csv(filename, csv_contents, folder_id)
      drive.create_file({ name: filename, parents: [folder_id] },
                        fields: "id",
                        upload_source: StringIO.new(csv_contents),
                        supports_all_drives: true,
                        content_type: "text/csv")
    end

    def share_file(file_id, recipients, notification_personalisation)
      grant_file_permissions(file_id, recipients)

      file_url = "https://drive.google.com/file/d/#{file_id}/view"
      send_notifications(
        recipients,
        notification_personalisation.merge(file_url: file_url),
      )
    end

  private

    attr_reader :drive, :notify_client

    def grant_file_permissions(file_id, recipients)
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

    def send_notifications(recipients, personalisation)
      recipients.each do |email_address|
        notify_client.send_email(email_address: email_address,
                                 template_id: NOTIFY_TEMPLATE_ID,
                                 email_reply_to_id: NOTIFY_REPLY_TO_ID,
                                 personalisation: personalisation)
      end
    end
  end
end
