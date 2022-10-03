require "tmpdir"

RSpec.describe "File export" do
  around do |example|
    expect { example.run }.to output.to_stdout
  end

  let!(:smart_survey_request) do
    survey_id = AskExport.config(:survey_id)
    responses = ask_smart_survey_responses(50)
    stub_get_responses(survey_id, responses).first
  end

  it "fetches surveys and creates files for them" do
    dlp_client = stub_dlp_client
    expect_deidentify_to_called(dlp_client, [match(/Answer/)] * 50, ["A question?"] * 50)

    AskExport::Targets.clear_cache
    stub_drive_authentication

    expected_exports = {
      filesystem: [],
      google_drive: %w[cabinet-office third-party],
    }

    google_drive_stubs = expected_exports[:google_drive].map do |recipient|
      filename = "2020-05-06-2000-to-2020-05-07-1100-#{recipient}.csv"
      stub_google_drive_upload(filename, "#{recipient}-folder-id")
    end

    Dir.mktmpdir do |tmpdir|
      ClimateControl.modify(SMART_SURVEY_API_TOKEN: "token",
                            SMART_SURVEY_API_TOKEN_SECRET: "token",
                            OUTPUT_DIR: tmpdir,
                            SINCE_TIME: "2020-05-06 20:00",
                            UNTIL_TIME: "2020-05-07 11:00",
                            GOOGLE_CLOUD_PROJECT: "project-name",
                            FOLDER_ID_CABINET_OFFICE: "cabinet-office-folder-id",
                            FOLDER_ID_THIRD_PARTY: "third-party-folder-id") do
        Rake::Task["run_exports"].invoke
      end

      expect(smart_survey_request).to have_been_made

      expected_exports[:filesystem].each do |recipient|
        expect(File).to exist(File.join(tmpdir, "2020-05-06-2000-to-2020-05-07-1100-#{recipient}.csv"))
      end

      google_drive_stubs.each { |stub| expect(stub).to have_been_requested }
    end
  end
end
