RSpec.describe "Big Query export" do
  around do |example|
    expect { example.run }.to output.to_stdout
  end

  around do |example|
    ClimateControl.modify(SMART_SURVEY_API_TOKEN: "token",
                          SMART_SURVEY_API_TOKEN_SECRET: "token",
                          SINCE_TIME: "2020-05-06 10:00",
                          UNTIL_TIME: "2020-05-07 10:00") { example.run }
  end

  before do
    stub_big_query_authentication
    stub_big_query_dataset
    stub_big_query_table

    Rake::Task["big_query_export"].reenable
  end

  let!(:smart_survey_request) { stub_smart_survey_api }

  let!(:big_query_insert_request) { stub_big_query_insert_all }

  it "fetches surveys and uploads data to Biq Query" do
    Rake::Task["big_query_export"].invoke
    expect(smart_survey_request).to have_been_made
    expect(big_query_insert_request).to have_been_made
  end
end
