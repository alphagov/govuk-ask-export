require "tmpdir"

RSpec.describe "Split Smary Survey CSV Export" do
  around do |example|
    travel_to(Time.zone.parse("2020-05-01 10:00")) { example.run }
  end

  before do
    Rake::Task["split_csv_export"].reenable
  end

  context "when a file is given" do
    around do |example|
      expect { example.run }.to output.to_stdout
    end

    it "can split a CSV export into files for each partner" do
      csv_path = File.join(__dir__, "../support/files/live_export.csv")
      Dir.mktmpdir do |tmpdir|
        ClimateControl.modify(CSV_FILE: csv_path, OUTPUT_DIR: tmpdir) do
          Rake::Task["split_csv_export"].invoke
        end

        expect(File).to exist(File.join(tmpdir, "2020-05-01-cabinet-office.csv"))
        expect(File).to exist(File.join(tmpdir, "2020-05-01-third-party.csv"))
      end
    end
  end

  context "when a file is not given" do
    around do |example|
      ClimateControl.modify(CSV_FILE: nil) { example.run }
    end

    it "raises an error" do
      expect { Rake::Task["split_csv_export"].invoke }
        .to raise_error("usage: CSV_FILE=/path/to/file.csv bundle exec rake split_csv_export")
    end
  end
end
