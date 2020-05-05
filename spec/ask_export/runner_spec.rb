RSpec.describe AskExport::Runner do
  describe ".call" do
    context "on and after 10am" do
      around do |example|
        travel_to(Time.zone.parse("2020-05-01 10:00")) { example.run }
      end

      around do |example|
        expect { example.run }.to output.to_stdout
      end

      around do |example|
        ClimateControl.modify(S3_BUCKET: s3_bucket,
                              S3_PATH_PREFIX: s3_path_prefix) { example.run }
      end

      before do
        allow(AskExport::SurveyResponseFetcher).to receive(:call).and_return(responses)
        allow(Aws::S3::Resource).to receive(:new).and_return(s3_resource_stub)
      end

      let(:responses) { [presented_survey_response] }
      let(:since_time) { Time.zone.parse("2020-04-30 10:00") }
      let(:until_time) { Time.zone.parse("2020-05-01 10:00") }
      let(:s3_bucket) { "s3-bucket" }
      let(:s3_path_prefix) { "prefix/" }
      let(:s3_resource_stub) { Aws::S3::Resource.new(stub_responses: true) }

      it "fetches survey responses for 10am previous day to 10am current day in local timezone" do
        expect(AskExport::SurveyResponseFetcher)
          .to receive(:call)
          .with(since_time, until_time)
          .and_yield(100)
          .and_return(responses)
        described_class.call
      end

      it "uploads cabinet office and third party CSVs to S3" do
        csv_builder = instance_double(AskExport::CsvBuilder,
                                      cabinet_office: "cabinet-office-data",
                                      third_party: "third-party-data")

        expect(AskExport::CsvBuilder).to receive(:new).and_return(csv_builder)
        expect(s3_resource_stub.client).to receive(:put_object)
                                       .with(bucket: s3_bucket,
                                             key: "#{s3_path_prefix}cabinet-office/2020-05-01.csv",
                                             body: "cabinet-office-data")

        expect(s3_resource_stub.client).to receive(:put_object)
                                       .with(bucket: s3_bucket,
                                             key: "#{s3_path_prefix}third-party/2020-05-01.csv",
                                             body: "third-party-data")
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
