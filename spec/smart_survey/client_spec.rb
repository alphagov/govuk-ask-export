RSpec.describe SmartSurvey::Client do
  let(:survey_id) { "123456789" }
  let(:client) { described_class.new }

  describe "#list_responses" do
    before do
      allow_any_instance_of(described_class).to receive(:sleep)
      allow_any_instance_of(Faraday::Request::Retry).to receive(:sleep)
    end

    around do |example|
      expect { example.run }.to output.to_stdout
    end

    let(:since_time) { Time.zone.parse("2020-04-30 10:00") }
    let(:until_time) { Time.zone.parse("2020-05-01 10:00") }

    it "make the requests with correct parameters" do
      responses = smart_survey_responses(200)
      requests = stub_get_responses(
        survey_id, responses, "Og==", { since_time: since_time, until_time: until_time }
      )

      client.list_responses(
        survey_id: survey_id, since_time: since_time, until_time: until_time,
      )

      requests.each { |request| expect(request).to have_been_made }
    end

    it "returns an array of responses" do
      stub_get_responses(survey_id, smart_survey_responses(2), "Og==")
      responses = client.list_responses(survey_id: survey_id)

      expect(responses).to contain_exactly(
        an_instance_of(SmartSurvey::Response),
        an_instance_of(SmartSurvey::Response),
      )
    end

    it "can retreive more responses than maximum page size of 100" do
      stub_get_responses(survey_id, smart_survey_responses(250), "Og==")
      responses = client.list_responses(survey_id: survey_id)

      expect(responses.count).to eq(250)
    end

    it "sleeps between each request" do
      stub_get_responses(survey_id, smart_survey_responses(250), "Og==")

      expect_any_instance_of(described_class).to receive(:sleep).twice
      client.list_responses(survey_id: survey_id)
    end
  end

  describe "#delete_response" do
    it "makes request with correct parameters" do
      response_id = "987654321"
      request = stub_delete_response(survey_id, response_id, "Og==")

      client.delete_response(survey_id: survey_id, response_id: response_id)

      expect(request).to have_been_made
    end
  end
end
