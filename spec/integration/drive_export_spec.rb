RSpec.describe "Drive export" do
  around do |example|
    expect { example.run }.to output.to_stdout
  end

  before do
    allow(Google::Auth::ServiceAccountCredentials).to receive(:make_creds)
                                                  .and_return("secret credentials")
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

  it "fetches surveys, uploads CSV files to drive and sets permissions on each" do
    ClimateControl.modify(SMART_SURVEY_API_TOKEN: "token",
                          SMART_SURVEY_API_TOKEN_SECRET: "token",
                          CABINET_OFFICE_DRIVE_FOLDER: "cabinet-office-folder-id",
                          CABINET_OFFICE_RECIPIENTS: "cabinet-office@example.com",
                          DATA_LABS_DRIVE_FOLDER: "data-labs-folder-id",
                          DATA_LABS_RECIPIENTS: "data-labs@example.com",
                          PERFORMANCE_ANALYST_DRIVE_FOLDER: "performance-analyst-folder-id",
                          PERFORMANCE_ANALYST_RECIPIENTS: "performance-analyst@example.com",
                          THIRD_PARTY_DRIVE_FOLDER: "third-party-folder-id",
                          THIRD_PARTY_RECIPIENTS: "third-party@example.com",
                          SINCE_TIME: "2020-05-06 20:00",
                          UNTIL_TIME: "2020-05-07 11:00") do
      Rake::Task["drive_export"].invoke
    end

    expect(smart_survey_request).to have_been_made
    expect(upload_request).to have_been_made.times(4)
    expect(permission_request).to have_been_made.times(4)
  end
end
