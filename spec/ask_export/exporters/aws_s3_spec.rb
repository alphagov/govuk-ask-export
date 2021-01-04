RSpec.describe AskExport::Exporters::AwsS3 do
  describe "#export" do
    it "makes a put object call to AWS S3" do
      stubbed_client = stub_aws_s3_client

      exporter = AskExport::Exporters::AwsS3.new
      ClimateControl.modify S3_BUCKET_NAME_PIPELINE_NAME: "bucket-name" do
        exporter.export("pipeline-name", "file.csv", "data")
      end

      expect(stubbed_client.api_requests.size).to eq(1)
      expect(stubbed_client.api_requests.first[:params]).to include(
        body: be_a(StringIO),
        bucket: "bucket-name",
        key: "file.csv",
        server_side_encryption: "AES256",
      )
    end
  end

  describe "#bucket_name_from_env" do
    it "returns an bucket name" do
      ClimateControl.modify S3_BUCKET_NAME_SOME_NAME: "bucket-name" do
        bucket_name = AskExport::Exporters::AwsS3.bucket_name_from_env("some-name")
        expect(bucket_name).to eq("bucket-name")
      end
    end
  end
end
