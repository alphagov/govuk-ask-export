module AwsS3Helper
  def stub_aws_s3_client
    stubbed_client = Aws::S3::Client.new(stub_responses: true)
    allow(Aws::S3::Client).to receive(:new).and_return(stubbed_client)

    stubbed_client
  end
end
