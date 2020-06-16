module BigQueryHelper
  def stub_big_query_authentication
    # Some rather hacky short circuits to bypass google authentication
    allow(Google::Cloud::Bigquery::Credentials)
      .to receive(:default)
      .and_return({ "private_key": OpenSSL::PKey::RSA.generate(1024).to_s })

    stub_request(:post, "https://oauth2.googleapis.com/token")
      .and_return(body: "{}", headers: { content_type: "application/json" })
  end

  def stub_big_query_dataset
    stub_request(:get, /bigquery.googleapis.com.*\/datasets\/ask_test_dataset$/)
      .and_return(body: { datasetReference: { projectId: "123", datasetId: "123" } }.to_json,
                  headers: { content_type: "application/json" })
  end

  def stub_big_query_table
    response = { tableReference: { projectId: "123", datasetId: "123", tableId: "123" } }
    stub_request(:any, /bigquery.googleapis.com.*\/tables/)
      .and_return(body: response.to_json,
                  headers: { content_type: "application/json" })
  end

  def stub_big_query_insert_all
    stub_request(:post, /bigquery.googleapis.com.*\/insertAll$/)
      .and_return(body: "{}", headers: { content_type: "application/json" })
  end
end
