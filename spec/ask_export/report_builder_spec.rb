RSpec.describe AskExport::ReportBuilder do
  let(:secret_key) { "secret" }

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
      responses = [serialised_survey_response({ id: 1 })]
      expected_responses = [report_response({ id: 1 }, secret_key)]

      expect(AskExport::SurveyResponseFetcher)
        .to receive(:call)
        .with(instance.since_time, instance.until_time)
        .and_return(responses)

      ClimateControl.modify(SECRET_KEY: secret_key) do
        expect(instance.responses).to eq(expected_responses)
      end
    end
  end

  describe "#completed_responses" do
    it "returns only completed survey responses" do
      responses = [
        serialised_survey_response(status: "completed", id: 1),
        serialised_survey_response(status: "partial"),
        serialised_survey_response(status: "disqualified"),
      ]

      expected_responses = [report_response({ id: 1 }, secret_key)]

      allow(AskExport::SurveyResponseFetcher)
        .to receive(:call)
        .and_return(responses)

      ClimateControl.modify(SECRET_KEY: secret_key) do
        expect(described_class.new.completed_responses).to eq(expected_responses)
      end
    end
  end

  describe "#build" do
    let(:responses) do
      [
        serialised_survey_response(status: "completed", id: 1),
        serialised_survey_response(status: "partial", id: 2),
      ]
    end

    before do
      allow(AskExport::SurveyResponseFetcher)
        .to receive(:call)
        .and_return(responses)
    end

    it "returns a report with only completed responses" do
      expected_responses = [report_response({ id: 1 }, secret_key)]

      expect(AskExport::Report).to receive(:new)
        .with(
          expected_responses,
          Time.zone.parse("2020-04-30 10:00"),
          Time.zone.parse("2020-05-01 10:00"),
        )

      ClimateControl.modify(SECRET_KEY: secret_key) do
        described_class.new.build(true)
      end
    end

    it "returns a report with all responses" do
      expected_responses = [
        report_response({ id: 1 }, secret_key),
        report_response({ status: "partial", id: 2 }, secret_key),
      ]

      expect(AskExport::Report).to receive(:new)
        .with(
          expected_responses,
          Time.zone.parse("2020-04-30 10:00"),
          Time.zone.parse("2020-05-01 10:00"),
        )

      ClimateControl.modify(SECRET_KEY: secret_key) do
        described_class.new.build(false)
      end
    end
  end
end
