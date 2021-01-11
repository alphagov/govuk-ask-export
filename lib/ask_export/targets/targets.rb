module AskExport
  module Targets
    def self.load_all
      {
        "aws_s3" => AwsS3.new,
        "google_drive" => GoogleDrive.new,
        "filesystem" => Filesystem.new,
      }
    end
  end
end
