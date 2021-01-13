RSpec.describe AskExport::ReportBuilder do
  around do |example|
    travel_to(Time.zone.parse("2020-05-01 12:00")) { example.run }
  end

  describe "#since_time" do
    it "defaults to 12am on the previous day in the current time zone" do
      expect(described_class.new.since_time)
        .to eq(Time.zone.parse("2020-04-30 00:00"))
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
    it "defaults to 12am on the current day in the current time zone" do
      expect(described_class.new.until_time)
        .to eq(Time.zone.parse("2020-05-01 00:00"))
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
      responses = [serialised_survey_response(id: 1)]
      expected_responses = [serialised_survey_response(id: 1, question: "REDACTED1")]

      expect(AskExport::SurveyResponseFetcher)
        .to receive(:call)
        .with(instance.since_time, instance.until_time)
        .and_return(responses)

      stub_deidentify(1)

      expect(instance.responses).to eq(expected_responses)
    end
  end

  describe "#completed_responses" do
    it "returns only completed survey responses" do
      responses = [
        serialised_survey_response(status: "completed", id: 1),
        serialised_survey_response(status: "partial"),
        serialised_survey_response(status: "disqualified"),
      ]

      expected_responses = [serialised_survey_response(id: 1, question: "REDACTED1")]

      allow(AskExport::SurveyResponseFetcher)
        .to receive(:call)
        .and_return(responses)

      stub_deidentify(3)

      expect(described_class.new.completed_responses).to eq(expected_responses)
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
      expected_responses = [serialised_survey_response(id: 1, question: "REDACTED1")]
      stub_deidentify(2)

      expect(AskExport::Report).to receive(:new)
        .with(
          expected_responses,
          Time.zone.parse("2020-04-30 00:00"),
          Time.zone.parse("2020-05-01 00:00"),
        )

      described_class.new.build(true)
    end

    it "returns a report with all responses" do
      expected_responses = [
        serialised_survey_response(id: 1, question: "REDACTED1"),
        serialised_survey_response(status: "partial", id: 2),
      ]
      stub_deidentify(1)

      expect(AskExport::Report).to receive(:new)
        .with(
          expected_responses,
          Time.zone.parse("2020-04-30 00:00"),
          Time.zone.parse("2020-05-01 00:00"),
        )

      described_class.new.build(false)
    end
  end

  def stub_deidentify(number_of_values)
    deidentifier = instance_double("AskExport::Deidentifier")
    allow(AskExport::Deidentifier)
      .to receive(:new)
      .and_return(deidentifier)

    return_values = Array.new(number_of_values) { |i| "REDACTED#{i + 1}" }

    allow(deidentifier).to receive(:bulk_deidentify).and_return(return_values)
  end
end
