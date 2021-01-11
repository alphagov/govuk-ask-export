require "tmpdir"

RSpec.describe "File export" do
  around do |example|
    expect { example.run }.to output.to_stdout
  end

  let!(:smart_survey_request) { stub_smart_survey_api }

  it "fetches surveys and creates files for them" do
    dlp_client = stub_dlp_client
    expect_deidentify_to_called(dlp_client, ["A question?"] * 50, ["A question?"] * 50)

    s3_client = stub_aws_s3_client
    stub_drive_authentication

    expected_exports = {
      filesystem: [],
      google_drive: %w[cabinet-office third-party],
      aws_s3: %w[gcs-public-questions],
    }

    google_drive_stubs = expected_exports[:google_drive].map do |recipient|
      filename = "2020-05-06-2000-to-2020-05-07-1100-#{recipient}.csv"
      stub_google_drive_upload(filename, "#{recipient}-folder-id")
    end

    Dir.mktmpdir do |tmpdir|
      ClimateControl.modify(SMART_SURVEY_API_TOKEN: "token",
                            SMART_SURVEY_API_TOKEN_SECRET: "token",
                            OUTPUT_DIR: tmpdir,
                            SECRET_KEY: SecureRandom.uuid,
                            SINCE_TIME: "2020-05-06 20:00",
                            UNTIL_TIME: "2020-05-07 11:00",
                            GOOGLE_CLOUD_PROJECT: "project-name",
                            FOLDER_ID_CABINET_OFFICE: "cabinet-office-folder-id",
                            FOLDER_ID_THIRD_PARTY: "third-party-folder-id",
                            S3_BUCKET_NAME_GCS_PUBLIC_QUESTIONS: "bucket-name") do
        Rake::Task["run_exports"].invoke
      end

      expect(smart_survey_request).to have_been_made

      expected_exports[:filesystem].each do |recipient|
        expect(File).to exist(File.join(tmpdir, "2020-05-06-2000-to-2020-05-07-1100-#{recipient}.csv"))
      end

      google_drive_stubs.each { |stub| expect(stub).to have_been_requested }

      expect(s3_client.api_requests.size).to eq(expected_exports[:aws_s3].count)

      aws_requests = s3_client.api_requests.map { |r| r[:params] }

      expected_aws_requests = expected_exports[:aws_s3].map do |recipient|
        include(
          body: be_a(StringIO),
          bucket: "bucket-name",
          key: "2020-05-06-2000-to-2020-05-07-1100-#{recipient}.csv",
          server_side_encryption: "AES256",
        )
      end

      expect(aws_requests).to include(*expected_aws_requests)
    end
  end
end
