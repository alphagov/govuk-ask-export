RSpec.describe AskExport::BigQueryExport do
  describe ".call" do
    around do |example|
      travel_to(Time.zone.parse("2020-05-01 10:00")) { example.run }
    end

    context "when time is not from 10am to 10am" do
      it "warns" do
        expect { described_class.call }.to output(warning).to_stderr
      end
    end
  end
end
