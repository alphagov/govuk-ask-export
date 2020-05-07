RSpec.describe AskExport::FileExport do
  around do |example|
    travel_to(Time.zone.parse("2020-05-01 10:00")) { example.run }
  end

  around do |example|
    expect { example.run }.to output.to_stdout
  end

  before do
    allow(File).to receive(:write)
    allow(AskExport::Report).to receive(:new).and_return(stubbed_report)
  end

  it "writes files for each partner named with current date" do
    csv_builder = instance_double(AskExport::CsvBuilder,
                                  cabinet_office: "cabinet-office-data",
                                  third_party: "third-party-data")
    allow(AskExport::CsvBuilder).to receive(:new).and_return(csv_builder)

    described_class.call

    expect(File)
      .to have_received(:write)
      .with(File.expand_path("../../output/2020-04-30-1000-to-2020-05-01-1000-cabinet-office.csv", __dir__),
            csv_builder.cabinet_office,
            mode: "w")
    expect(File)
      .to have_received(:write)
      .with(File.expand_path("../../output/2020-04-30-1000-to-2020-05-01-1000-third-party.csv", __dir__),
            csv_builder.third_party,
            mode: "w")
  end
end
