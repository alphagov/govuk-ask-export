require "google/apis/drive_v3"
require "googleauth"

module AskExport
  module Targets
    class GoogleDrive
      SCOPE = Google::Apis::DriveV3::AUTH_DRIVE

      def self.folder_id_from_env(name)
        env_var_name = "FOLDER_ID_#{name.upcase.gsub(/-/, '_')}"
        ENV[env_var_name]
      end

      def initialize
        @drive_service = Google::Apis::DriveV3::DriveService.new
        @drive_service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(scope: SCOPE)
      end

      def export(pipeline_name, filename, data)
        file = StringIO.new(data)
        folder_id = GoogleDrive.folder_id_from_env(pipeline_name)

        @drive_service.create_file({ name: filename, parents: [folder_id] },
                                   fields: "id",
                                   upload_source: file,
                                   supports_all_drives: true,
                                   content_type: "text/csv")

        puts "Google Drive export: #{filename} uploaded to https://drive.google.com/drive/folders/#{folder_id}"
      end

      def cleanup(pipeline_name)
        folder_id = GoogleDrive.folder_id_from_env(pipeline_name)

        files = @drive_service.list_files(
          q: "'#{folder_id}' in parents",
          include_items_from_all_drives: true,
          supports_all_drives: true,
          fields: "files(id,name,createdTime)",
          page_size: 1000,
        ).files

        puts "Google Drive: Found #{files.count} existing files"
        files.each do |file|
          next if file.created_time > 3.months.ago

          puts "Google Drive: Deleting file #{file.name}"
          @drive_service.delete_file(
            file.id,
            supports_all_drives: true,
          )
        end
      end
    end
  end
end
