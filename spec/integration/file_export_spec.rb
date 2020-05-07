RSpec.describe "File export" do
  around do |example|
    travel_to(Time.zone.parse("2020-05-01 10:00")) { example.run }
  end

  around do |example|
    expect { example.run }.to output.to_stdout
  end

  let!(:smart_survey_request) { stub_smart_survey_api }

  it "fetches surveys and creates files for them" do
    Dir.mktmpdir do |tmpdir|
      ClimateControl.modify(SMART_SURVEY_API_TOKEN: "token",
                            SMART_SURVEY_API_TOKEN_SECRET: "token",
                            OUTPUT_DIR: tmpdir) do
        Rake::Task["file_export"].invoke
      end

      expect(smart_survey_request).to have_been_made
      expect(File).to exist(File.join(tmpdir, "2020-04-30-1000-to-2020-05-01-1000-cabinet-office.csv"))
      expect(File).to exist(File.join(tmpdir, "2020-04-30-1000-to-2020-05-01-1000-third-party.csv"))
    end
  end
end
