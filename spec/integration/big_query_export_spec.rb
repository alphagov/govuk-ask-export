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
    # Some rather hacky short circuits to bypass google authentication
    allow(Google::Cloud::Bigquery::Credentials)
      .to receive(:default)
      .and_return({ "private_key": OpenSSL::PKey::RSA.generate(1024).to_s })

    stub_request(:post, "https://oauth2.googleapis.com/token")
      .and_return(body: "{}", headers: { content_type: "application/json" })

    stub_dataset_request
    stub_any_table_request

    Rake::Task["big_query_export"].reenable
  end

  def stub_dataset_request
    stub_request(:get, /bigquery.googleapis.com.*\/datasets\/ask_test_dataset$/)
      .and_return(body: { datasetReference: { projectId: "123", datasetId: "123" } }.to_json,
                  headers: { content_type: "application/json" })
  end

  def stub_any_table_request
    response = { tableReference: { projectId: "123", datasetId: "123", tableId: "123" } }
    stub_request(:any, /bigquery.googleapis.com.*\/tables/)
      .and_return(body: response.to_json,
                  headers: { content_type: "application/json" })
  end

  let!(:smart_survey_request) { stub_smart_survey_api }

  let!(:big_query_insert_request) do
    stub_request(:post, /bigquery.googleapis.com.*\/insertAll$/)
      .and_return(body: "{}", headers: { content_type: "application/json" })
  end

  it "fetches surveys and uploads data to Biq Query" do
    Rake::Task["big_query_export"].invoke
    expect(smart_survey_request).to have_been_made
    expect(big_query_insert_request).to have_been_made
  end
end
