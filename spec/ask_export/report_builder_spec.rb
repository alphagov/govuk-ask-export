RSpec.describe AskExport::ReportBuilder do
  let(:client) { instance_double("SmartSurvey::Client") }

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
    it "returns deidentified responses" do
      instance = described_class.new
      responses = [build(:ask_response, id: 1, question: "Question with PII")]

      allow(SmartSurvey::Client).to receive(:new).and_return(client)
      allow(client).to receive(:list_responses)
        .with(survey_id: 849_813,
              response_class: AskExport::Response,
              since_time: instance.since_time,
              until_time: instance.until_time)
        .and_return(responses)

      stub_deidentify(1)

      expect(instance.responses).to contain_exactly(
        have_attributes(id: 1, question: "REDACTED1"),
      )
    end
  end

  describe "#completed_responses" do
    it "returns only completed survey responses" do
      instance = described_class.new
      responses = [
        build(:ask_response, id: 1),
        build(:ask_response, id: 2, status: "partial"),
        build(:ask_response, id: 3, status: "disqualified"),
      ]

      allow(SmartSurvey::Client).to receive(:new).and_return(client)
      allow(client).to receive(:list_responses).and_return(responses)

      stub_deidentify(3)

      expect(instance.completed_responses).to contain_exactly(
        have_attributes(id: 1),
      )
    end
  end

  describe "#build" do
    let(:responses) do
      [
        build(:ask_response, id: 1),
        build(:ask_response, id: 2, status: "partial"),
      ]
    end

    before do
      allow(SmartSurvey::Client).to receive(:new).and_return(client)
      allow(client).to receive(:list_responses).and_return(responses)
    end

    it "returns a report with only completed responses" do
      stub_deidentify(2)

      expect(AskExport::Report).to receive(:new)
        .with(
          responses[0..0],
          Time.zone.parse("2020-04-30 10:00"),
          Time.zone.parse("2020-05-01 10:00"),
        )

      described_class.new.build(true)
    end

    it "returns a report with all responses" do
      stub_deidentify(1)

      expect(AskExport::Report).to receive(:new)
        .with(
          responses,
          Time.zone.parse("2020-04-30 10:00"),
          Time.zone.parse("2020-05-01 10:00"),
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
