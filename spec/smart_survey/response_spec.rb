RSpec.describe SmartSurvey::Response do
  describe "#parse" do
    let(:response_id) { 123_456_789 }
    let(:started) { Time.zone.parse("2020-04-30 10:00") }
    let(:ended) { Time.zone.parse("2020-05-01 10:00") }

    it "returns an object top level atrributes" do
      raw_response = hash(:response,
                          id: response_id,
                          date_started: started.iso8601,
                          date_ended: ended.iso8601,
                          status: "completed")

      response = described_class.parse(raw_response)
      expect(response).to have_attributes(
        id: response_id,
        status: "completed",
        started: started,
        ended: ended,
      )
    end

    context "no pages" do
      it "returns object with no answers" do
        raw_response = hash(:response, pages: [])

        response = described_class.parse(raw_response)
        expect(response).to have_attributes(answers: {})
      end
    end

    context "a text question" do
      it "returns object with an answer" do
        question = hash(:question, :text)
        pages = [hash(:page, questions: [question])]

        raw_response = hash(:response, pages: pages)

        response = described_class.parse(raw_response)
        expect(response).to have_attributes(
          answers: { question[:id] => question[:answers].first[:value] },
        )
      end
    end

    context "mutliple pages with questions" do
      it "returns object with all answers" do
        question1 = hash(:question, :dropdown)
        question2 = hash(:question, :radio)
        question3 = hash(:question, :essay)

        raw_response = hash(
          :response,
          pages: [
            hash(:page, questions: [question1]),
            hash(:page, questions: [question2]),
            hash(:page, questions: [question3]),
          ],
        )

        response = described_class.parse(raw_response)
        expect(response).to have_attributes(
          answers: {
            question1[:id] => question1[:answers].first[:choice_title],
            question2[:id] => question2[:answers].first[:choice_title],
            question3[:id] => question3[:answers].first[:value],
          },
        )
      end
    end

    context "mutliple questions per page" do
      it "returns object with all answers" do
        question1 = hash(:question, :dropdown)
        question2 = hash(:question, :radio)
        question3 = hash(:question, :essay)

        raw_response = hash(
          :response,
          pages: [hash(:page, questions: [question1, question2, question3])],
        )

        response = described_class.parse(raw_response)
        expect(response).to have_attributes(
          answers: {
            question1[:id] => question1[:answers].first[:choice_title],
            question2[:id] => question2[:answers].first[:choice_title],
            question3[:id] => question3[:answers].first[:value],
          },
        )
      end
    end
  end

  describe "#completed?" do
    it "returns true if status is completed" do
      response = described_class.new(
        id: nil, status: "completed", started: nil, ended: nil, answers: [],
      )

      expect(response.completed?).to be(true)
    end

    it "returns true if status is partial" do
      response = described_class.new(
        id: nil, status: "partial", started: nil, ended: nil, answers: [],
      )

      expect(response.completed?).to be(false)
    end
  end
end
