RSpec.describe AskExport::Report do
  around do |example|
    travel_to(Time.zone.parse("2020-05-01 12:00")) { example.run }
  end

  describe "#since_time" do
    it "returns 10am on the previous day in current time zone" do
      expect(described_class.new.since_time)
        .to eq(Time.zone.parse("2020-04-30 10:00"))
    end
  end

  describe "#until_time" do
    it "returns 10am on the current day in current time zone" do
      expect(described_class.new.until_time)
        .to eq(Time.zone.parse("2020-05-01 10:00"))
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

  describe "#filename_prefix" do
    it "returns a the time range as a prefix" do
      expect(described_class.new.filename_prefix)
        .to eq("2020-04-30-1000-to-2020-05-01-1000")
    end
  end
end
