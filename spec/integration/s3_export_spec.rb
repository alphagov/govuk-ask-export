RSpec.describe "S3 export" do
  around do |example|
    ClimateControl.modify(
      SMART_SURVEY_API_TOKEN: "token",
      SMART_SURVEY_API_TOKEN_SECRET: "token",
      AWS_ACCESS_KEY_ID: "12345",
      AWS_SECRET_ACCESS_KEY: "secret",
      AWS_REGION: "eu-west-1",
      S3_BUCKET: "bucket",
      NOTIFY_API_KEY: "#{SecureRandom.uuid}-#{SecureRandom.uuid}",
      CABINET_OFFICE_EMAIL_RECIPIENTS: "test@example.com",
      DATA_LABS_EMAIL_RECIPIENTS: "test@example.com",
      PERFORMANCE_ANALYST_EMAIL_RECIPIENTS: "test@example.com",
      THIRD_PARTY_EMAIL_RECIPIENTS: "test@example.com",
      SINCE_TIME: "2020-05-06 20:00",
      UNTIL_TIME: "2020-05-07 11:00",
    ) { example.run }
  end

  around do |example|
    expect { example.run }.to output.to_stdout
  end

  let!(:smart_survey_request) { stub_smart_survey_api }
  let!(:s3_request) do
    stub_request(:put, /bucket\.s3\.eu-west-1\.amazonaws\.com/)
  end

  let!(:notify_request) do
    stub_request(:post, /api\.notifications\.service\.gov\.uk/)
      .and_return(body: "{}")
  end

  it "fetches surveys and uploads them to s3" do
    Rake::Task["s3_export"].invoke
    expect(smart_survey_request).to have_been_made
    expect(s3_request).to have_been_made.times(4)
    expect(notify_request).to have_been_made.times(4)
  end
end
