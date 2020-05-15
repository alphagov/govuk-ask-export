RSpec.describe AskExport::Report do
  around do |example|
    travel_to(Time.zone.parse("2020-05-01 12:00")) { example.run }
  end

  describe "#since_time" do
    it "defaults to 10am on the previous day in the current time zone" do
      expect(described_class.new.since_time)
        .to eq(Time.zone.parse("2020-04-30 10:00"))
    end

    it "can use the SINCE_TIME environment variable to specify the relative time on " \
       "the previous day" do
      ClimateControl.modify(SINCE_TIME: "12:16") do
        expect(described_class.new.since_time).to eq(Time.zone.parse("2020-04-30 12:16"))
      end
    end

    it "can be overridden with an absolute time with the SINCE_TIME environment variable" do
      ClimateControl.modify(SINCE_TIME: "2020-01-01 12:16") do
        expect(described_class.new.since_time).to eq(Time.zone.parse("2020-01-01 12:16"))
      end
    end

    it "raises an ArgumentError when given a time that can't be parsed" do
      ClimateControl.modify(SINCE_TIME: "Not a real time") do
        expect { described_class.new.since_time }
          .to raise_error(ArgumentError, %("Not a real time" could not be parsed as a time))
      end
    end
  end

  describe "#until_time" do
    it "defaults to 10am on the current day in the current time zone" do
      expect(described_class.new.until_time)
        .to eq(Time.zone.parse("2020-05-01 10:00"))
    end

    it "can be overridden with the UNTIL_TIME environment variable" do
      ClimateControl.modify(UNTIL_TIME: "2020-01-01 12:16") do
        expect(described_class.new.until_time).to eq(Time.zone.parse("2020-01-01 12:16"))
      end
    end
  end

  describe "#responses" do
    it "delegates to SurveyResponseFetcher" do
      instance = described_class.new
      responses = [presented_survey_response]
      expect(AskExport::SurveyResponseFetcher)
        .to receive(:call)
        .with(instance.since_time, instance.until_time)
        .and_return(responses)
      expect(instance.responses).to eq(responses)
    end
  end

  describe "#completed_responses" do
    it "returns only completed survey responses" do
      completed_response = presented_survey_response(status: "completed")
      partial_response = presented_survey_response(status: "partial")
      disqualified_response = presented_survey_response(status: "disqualified")

      allow(AskExport::SurveyResponseFetcher)
        .to receive(:call)
        .and_return([completed_response, partial_response, disqualified_response])

      expect(described_class.new.completed_responses).to eq([completed_response])
    end
  end

  describe "#filename_prefix" do
    it "returns a the time range as a prefix" do
      expect(described_class.new.filename_prefix)
        .to eq("2020-04-30-1000-to-2020-05-01-1000")
    end
  end
end
