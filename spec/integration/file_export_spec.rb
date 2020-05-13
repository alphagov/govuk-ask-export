RSpec.describe "File export" do
  around do |example|
    expect { example.run }.to output.to_stdout
  end

  let!(:smart_survey_request) { stub_smart_survey_api }

  it "fetches surveys and creates files for them" do
    Dir.mktmpdir do |tmpdir|
      ClimateControl.modify(SMART_SURVEY_API_TOKEN: "token",
                            SMART_SURVEY_API_TOKEN_SECRET: "token",
                            OUTPUT_DIR: tmpdir,
                            SINCE_TIME: "2020-05-06 20:00",
                            UNTIL_TIME: "2020-05-07 11:00") do
        Rake::Task["file_export"].invoke
      end

      expect(smart_survey_request).to have_been_made
      %w[cabinet-office data-labs performance-analyst third-party].each do |recipient|
        expect(File).to exist(File.join(tmpdir, "2020-05-06-2000-to-2020-05-07-1100-#{recipient}.csv"))
      end
    end
  end
end
