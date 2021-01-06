require "aws-sdk-s3"

module AskExport
  module Exporters
    class AwsS3
      def initialize
        @client = Aws::S3::Client.new
      end

      def export(pipeline_name, filename, data)
        file = StringIO.new(data)
        bucket_name = AwsS3.bucket_name_from_env(pipeline_name)

        @client.put_object({
          acl: "bucket-owner-full-control",
          body: file,
          bucket: bucket_name,
          key: filename,
          server_side_encryption: "AES256",
        })

        puts "AWS S3 Exporter: #{filename} uploaded to s3://#{bucket_name}"
      end

      def self.bucket_name_from_env(name)
        env_var_name = "S3_BUCKET_NAME_#{name.upcase.gsub(/-/, '_')}"
        ENV[env_var_name]
      end
    end
  end
end
