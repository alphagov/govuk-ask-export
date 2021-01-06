RSpec.describe AskExport::SurveyResponseFetcher do
  describe ".call" do
    before do
      allow_any_instance_of(described_class).to receive(:sleep)
      allow_any_instance_of(Faraday::Request::Retry).to receive(:sleep)
    end

    around do |example|
      travel_to(Time.zone.parse("2020-05-01 10:00")) { example.run }
    end

    around do |example|
      ClimateControl.modify(
        SMART_SURVEY_API_TOKEN: "token",
        SMART_SURVEY_API_TOKEN_SECRET: "secret",
      ) { example.run }
    end

    let(:since_time) { Time.zone.parse("2020-04-30 10:00") }
    let(:until_time) { Time.zone.parse("2020-05-01 10:00") }

    context "successful retrievals" do
      around do |example|
        expect { example.run }.to output.to_stdout
      end

      it "requests responses in smart survey covering the dates specified" do
        request = stub_smart_survey_api(since_time: since_time,
                                        until_time: until_time)
        described_class.call(since_time, until_time)
        expect(request).to have_been_made
      end

      it "delegates to ResponseSerialiser to serialise the response from Smart Survey" do
        record = smart_survey_row
        stub_smart_survey_api(body: [record])
        serialised_response = serialised_survey_response
        expect(described_class::ResponseSerialiser).to receive(:call)
                                                   .with(record)
                                                   .and_return(serialised_response)

        expect(described_class.call(since_time, until_time))
          .to eql([serialised_response])
      end

      it "requests multiple pages when there are more results than the page size" do
        page1_request = stub_smart_survey_api(body: smart_survey_response(100),
                                              page: 1)
        page2_request = stub_smart_survey_api(body: smart_survey_response(50),
                                              page: 2)

        results = described_class.call(since_time, until_time)

        expect(results.count).to eql(150)
        expect(page1_request).to have_been_made
        expect(page2_request).to have_been_made
      end

      it "sleeps between each request" do
        stub_smart_survey_api(body: smart_survey_response(100), page: 1)
        stub_smart_survey_api(body: smart_survey_response(100), page: 2)
        stub_smart_survey_api(body: smart_survey_response(50), page: 3)

        expect_any_instance_of(described_class).to receive(:sleep).twice
        described_class.call(since_time, until_time)
      end

      it "defaults to the draft environment" do
        draft_request = stub_smart_survey_api(environment: :draft)
        described_class.call(since_time, until_time)
        expect(draft_request).to have_been_made
      end

      it "can use the live environment" do
        live_request = stub_smart_survey_api(environment: :live)
        ClimateControl.modify(SMART_SURVEY_CONFIG: "live") do
          described_class.call(since_time, until_time)
        end
        expect(live_request).to have_been_made
      end
    end

    context "unsuccessful retrivals" do
      it "raises an error if until time is after the current time" do
        expect { described_class.call(since_time, Time.zone.now + 60) }
          .to raise_error(ArgumentError, "You are requesting an export for future data")
      end

      it "raises an error if since time is after the until time" do
        expect { described_class.call(Time.zone.now + 120, Time.zone.now + 60) }
          .to raise_error(ArgumentError, "Export since time must be before the until time")
      end

      it "retries 429 responses 3 times before raising an error" do
        request = stub_smart_survey_api(status: 429)
        expect { described_class.call(since_time, until_time) }
          .to output.to_stdout
          .and raise_error(Faraday::ClientError)
        expect(request).to have_been_made.times(4)
      end

      it "retries timeout responses 3 times before raising an error" do
        request = stub_request(:get, /api\.smartsurvey\.io/).to_timeout
        expect { described_class.call(since_time, until_time) }
          .to output.to_stdout
          .and raise_error(Faraday::ConnectionFailed)
        expect(request).to have_been_made.times(4)
      end

      it "doesn't retry other 4xx responses" do
        request = stub_smart_survey_api(status: 404)
        expect { described_class.call(since_time, until_time) }
          .to output.to_stdout
          .and raise_error(Faraday::ClientError)
        expect(request).to have_been_made.once
      end
    end
  end
end
