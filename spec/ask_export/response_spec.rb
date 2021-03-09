RSpec.describe AskExport::Response do
  let(:answers) do
    {
      12_861_884 => "England",
      12_861_887 => "Question?",
      12_861_888 => "Yes",
      12_861_883 => "Alex Doe",
      12_861_886 => "test@example.com",
      12_861_885 => "123456789",
    }
  end

  let(:started) { Time.zone.parse("2020-04-30 10:00") }
  let(:ended) { Time.zone.parse("2020-05-01 10:00") }

  describe "#new" do
    it "returns the initialize object with correct attributes" do
      response = described_class.new(
        id: 1,
        status: "completed",
        started: started,
        ended: ended,
        answers: answers,
        variables: { "event" => "disco" },
      )

      expect(response).to have_attributes(
        id: 1,
        status: "completed",
        start_time: started,
        end_time: ended,
        started: started,
        ended: ended,
        region: "England",
        question: "Question?",
        share_video: "Yes",
        name: "Alex Doe",
        email: "test@example.com",
        phone: "123456789",
        event: "disco",
      )
    end
  end

  describe "#status" do
    let(:params) do
      {
        id: 1,
        started: nil,
        ended: nil,
        answers: {},
        variables: {},
      }
    end

    it "return submitted status if not completed" do
      response = described_class.new(params.merge(status: "partial"))

      expect(response.status).to eq("partial")
    end

    it "returns 'partial' when status is completed but some answers are missing" do
      response = described_class.new(
        params.merge(status: "completed", answers: answers.merge(12_861_884 => nil)),
      )

      expect(response.status).to eq("partial")
    end

    it "returns 'completed' when status is completed and answers are present" do
      response = described_class.new(params.merge(status: "completed", answers: answers))

      expect(response.status).to eq("completed")
    end
  end
end
