require "tmpdir"

RSpec.describe "Daily export" do
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
                            SECRET_KEY: SecureRandom.uuid,
                            SINCE_TIME: "2020-05-06 10:00",
                            UNTIL_TIME: "2020-05-07 10:00") { example.run }
    end
  end

  before do
    stub_drive_authentication
    stub_drive_set_permissions
    stub_big_query_authentication
    stub_big_query_dataset
    stub_big_query_table
    stub_post_notify

    Rake::Task["daily_export"].reenable
  end

  let!(:smart_survey_request) { stub_smart_survey_api }
  let!(:drive_upload_request) { stub_drive_upload }
  let!(:big_query_insert_request) { stub_big_query_insert_all }

  it "fetches surveys, uploads CSV files to drive and inserts to Big Query" do
    Rake::Task["daily_export"].invoke

    expect(smart_survey_request).to have_been_made.once
    expect(drive_upload_request).to have_been_made.at_least_once
    expect(big_query_insert_request).to have_been_made
  end
end
