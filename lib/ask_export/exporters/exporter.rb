module AskExport
  module Exporters
    def self.load_all
      {
        "aws_s3" => AwsS3.new,
        "google_drive" => GoogleDrive.new,
        "local_filesystem" => LocalFilesystem.new,
      }
    end
  end
end
