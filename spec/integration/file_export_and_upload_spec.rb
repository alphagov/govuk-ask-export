require "tmpdir"

RSpec.describe "File export and upload" do
  around do |example|
    expect { example.run }.to output.to_stdout
  end

  let!(:smart_survey_request) { stub_smart_survey_api }

  it "fetches surveys and creates files for them" do
    stub_drive_authentication
    recipients = %w[cabinet-office data-labs performance-analyst third-party]

    file_upload_stubs = recipients.map do |recipient|
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
                            FOLDER_ID_CABINET_OFFICE: "cabinet-office-folder-id",
                            FOLDER_ID_DATA_LABS: "data-labs-folder-id",
                            FOLDER_ID_THIRD_PARTY: "third-party-folder-id",
                            FOLDER_ID_PERFORMANCE_ANALYST: "performance-analyst-folder-id") do
        Rake::Task["file_export_and_upload"].invoke
      end

      expect(smart_survey_request).to have_been_made
      file_upload_stubs.each { |stub| expect(stub).to have_been_requested }
    end
  end
end
