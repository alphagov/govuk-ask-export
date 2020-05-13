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
    allow(AskExport::Report).to receive(:new).and_return(stubbed_report)
    allow(Aws::S3::Resource).to receive(:new).and_return(s3_resource_stub)
    allow(AskExport::PartnerNotifier).to receive(:call)
  end

  describe ".call" do
    it "uploads cabinet office, data labs, performance_analyst and third party CSVs to S3" do
      csv_builder = instance_double(AskExport::CsvBuilder,
                                    cabinet_office: "cabinet-office-data",
                                    data_labs: "data-labs-data",
                                    performance_analyst: "performance-analyst-data",
                                    third_party: "third-party-data")

      expect(AskExport::CsvBuilder).to receive(:new).and_return(csv_builder)

      {
        "cabinet-office" => csv_builder.cabinet_office,
        "data-labs" => csv_builder.data_labs,
        "performance-analyst" => csv_builder.performance_analyst,
        "third-party" => csv_builder.third_party,
      }.each do |recipient, data|
        expect(s3_resource_stub.client)
          .to receive(:put_object)
          .with(bucket: s3_bucket,
                key: "#{s3_path_prefix + recipient}/2020-04-30-1000-to-2020-05-01-1000.csv",
                body: data)
      end
      described_class.call
    end

    it "notifies partners with the times and number of responses" do
      expect(AskExport::PartnerNotifier)
        .to receive(:call)
      described_class.call
    end
  end
end
