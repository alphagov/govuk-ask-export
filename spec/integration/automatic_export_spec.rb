RSpec.describe "Automatic export" do
  around do |example|
    ClimateControl.modify(
      SMART_SURVEY_API_TOKEN: "token",
      SMART_SURVEY_API_TOKEN_SECRET: "token",
    ) { example.run }
  end

  around do |example|
    travel_to(Time.zone.parse("2020-05-01 10:00")) { example.run }
  end

  around do |example|
    expect { example.run }.to output.to_stdout
  end

  let!(:smart_survey_request) { stub_smart_survey_api }

  it "fetches surveys" do
    Rake::Task["export"].invoke
    expect(smart_survey_request).to have_been_made
  end
end
