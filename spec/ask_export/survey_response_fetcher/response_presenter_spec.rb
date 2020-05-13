RSpec.describe AskExport::SurveyResponseFetcher::ResponsePresenter do
  describe ".call" do
    it "presents a smart survey response" do
      presented_response = presented_survey_response
      options = presented_response.merge(
        start_time: Time.zone.parse(presented_response[:start_time]),
        submission_time: Time.zone.parse(presented_response[:submission_time]),
      )
      expect(described_class.call(smart_survey_row(options)))
        .to eq(presented_response)
    end

    it "can present a draft smart survey response" do
      options = { question: "Draft question?", environment: :draft }
      expect(described_class.call(smart_survey_row(options)))
        .to match(hash_including(question: "Draft question?"))
    end

    it "formats timestamps in the Smart Survey UK format" do
      options = { start_time: Time.zone.parse("2020-05-01 10:45"),
                  submission_time: Time.zone.parse("2020-05-01 11:00") }
      expect(described_class.call(smart_survey_row(options)))
        .to match(hash_including(start_time: "01/05/2020 10:45:00",
                                 submission_time: "01/05/2020 11:00:00"))
    end

    it "copes on a partial response" do
      expect(described_class.call(smart_survey_row(status: "partial")))
        .to match(hash_including(status: "partial",
                                 question: nil))
    end

    it "copes on a disqualified response" do
      expect(described_class.call(smart_survey_row(status: "disqualified")))
        .to match(hash_including(status: "disqualified",
                                 question: nil))
    end

    it "can include a client_id" do
      expect(described_class.call(smart_survey_row(client_id: "947770117.1576778690")))
        .to match(hash_including(client_id: "947770117.1576778690"))
    end
  end
end
