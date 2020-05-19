require "tmpdir"

RSpec.describe "Drive export" do
  around do |example|
    expect { example.run }.to output.to_stdout
  end

  around do |example|
    Dir.mktmpdir do |tmpdir|
      ClimateControl.modify(SMART_SURVEY_API_TOKEN: "token",
                            SMART_SURVEY_API_TOKEN_SECRET: "token",
                            NOTIFY_API_KEY: "#{SecureRandom.uuid}-#{SecureRandom.uuid}",
                            CABINET_OFFICE_DRIVE_FOLDER: "cabinet-office-folder-id",
                            CABINET_OFFICE_RECIPIENTS: "cabinet-office@example.com",
                            DATA_LABS_DRIVE_FOLDER: "data-labs-folder-id",
                            DATA_LABS_RECIPIENTS: "data-labs@example.com",
                            PERFORMANCE_ANALYST_DRIVE_FOLDER: "performance-analyst-folder-id",
                            PERFORMANCE_ANALYST_RECIPIENTS: "performance-analyst@example.com",
                            THIRD_PARTY_DRIVE_FOLDER: "third-party-folder-id",
                            THIRD_PARTY_RECIPIENTS: "third-party@example.com",
                            OUTPUT_DIR: tmpdir,
                            SINCE_TIME: "2020-05-06 20:00",
                            UNTIL_TIME: "2020-05-07 11:00") { example.run }
    end
  end

  before do
    allow(Google::Auth::ServiceAccountCredentials).to receive(:make_creds)
                                                  .and_return("secret credentials")
    Rake::Task["drive_export"].reenable
  end

  let!(:smart_survey_request) { stub_smart_survey_api }
  let!(:upload_request) do
    stub_request(:post, %r{googleapis\.com/upload/drive/v3})
      .and_return(body: { id: 1 }.to_json,
                  headers: { content_type: "application/json",
                             # pretend the multi-request upload completed
                             x_goog_upload_status: "final" })
  end

  let!(:permission_request) do
    stub_request(:post, %r{googleapis\.com/batch/drive/v3})
      .with(body: %r{ /drive/v3/files/.*/permissions})
  end

  let!(:notify_request) do
    stub_request(:post, /api\.notifications\.service\.gov\.uk/)
      .and_return(body: "{}")
  end

  it "fetches surveys, uploads CSV files to drive and sets permissions on each" do
    Rake::Task["drive_export"].invoke

    expect(smart_survey_request).to have_been_made
    expect(upload_request).to have_been_made.times(4)
    expect(permission_request).to have_been_made.times(4)
    expect(notify_request).to have_been_made.times(4)
  end

  it "outputs a text file for use in creating a Concourse Slack notifcation" do
    Rake::Task["drive_export"].invoke

    expect(File).to exist(File.join(ENV["OUTPUT_DIR"], "slack-message.txt"))
  end
end
