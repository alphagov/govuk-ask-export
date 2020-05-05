RSpec.describe AskExport::Runner do
  describe ".call" do
    context "on and after 10am" do
      around do |example|
        travel_to(Time.zone.parse("2020-05-01 10:00")) { example.run }
      end

      around do |example|
        expect { example.run }.to output.to_stdout
      end

      before do
        allow(AskExport::SurveyResponseFetcher).to receive(:call).and_return(responses)
      end

      let(:responses) { [presented_survey_response] }
      let(:since_time) { Time.zone.parse("2020-04-30 10:00") }
      let(:until_time) { Time.zone.parse("2020-05-01 10:00") }

      it "fetches survey responses for 10am previous day to 10am current day in local timezone" do
        expect(AskExport::SurveyResponseFetcher)
          .to receive(:call)
          .with(since_time, until_time)
          .and_yield(100)
          .and_return(responses)
        described_class.call
      end
    end

    context "before 10am" do
      around do |example|
        travel_to(Time.zone.parse("2020-05-01 09:59")) { example.run }
      end

      it "raises an error" do
        expect { described_class.call }
          .to raise_error("Too early, submissions for today are still open")
      end
    end
  end
end
