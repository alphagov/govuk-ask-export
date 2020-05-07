RSpec.describe AskExport::S3Export do
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

  let(:s3_bucket) { "s3-bucket" }
  let(:s3_path_prefix) { "prefix/" }
  let(:s3_resource_stub) { Aws::S3::Resource.new(stub_responses: true) }

  before do
    allow(AskExport::DailyReport).to receive(:new).and_return(stubbed_daily_report)
    allow(Aws::S3::Resource).to receive(:new).and_return(s3_resource_stub)
    allow(AskExport::PartnerNotifier).to receive(:call)
  end

  describe ".call" do
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

    it "notifies partners with the times and number of responses" do
      expect(AskExport::PartnerNotifier)
        .to receive(:call)
      described_class.call
    end
  end
end
