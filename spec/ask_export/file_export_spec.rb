RSpec.describe AskExport::FileExport do
  describe ".call" do
    before do
      allow(AskExport::Exporters).to receive(:load_all).and_return(exporters)
      allow(AskExport::Pipeline).to receive(:load_all).and_return(pipelines)

      report_builder = instance_double("AskExport::ReportBuilder")
      allow(AskExport::ReportBuilder).to receive(:new).and_return(report_builder)

      allow(report_builder).to receive(:build).with(only_completed: true).and_return(
        instance_double("AskExport::Report", filename: "file-a.csv", to_csv: "completed-data"),
      )
      allow(report_builder).to receive(:build).with(only_completed: false).and_return(
        instance_double("AskExport::Report", filename: "file-b.csv", to_csv: "all-data"),
      )
    end

    let(:exporters) do
      {
        "exporter_a" => spy("ExporterA"),
        "exporter_b" => spy("ExporterB"),
      }
    end

    let(:pipelines) do
      [
        instance_double(
          AskExport::Pipeline,
          name: "pipeline-a",
          fields: %i[a b],
          only_completed: true,
          destinations: %w[exporter_a],
        ),
        instance_double(
          AskExport::Pipeline,
          name: "pipeline-b",
          fields: %i[x y],
          only_completed: false,
          destinations: %w[exporter_b],
        ),
      ]
    end

    it "calls export on all the exporters defined in the pipelines" do
      described_class.call

      expect(exporters["exporter_a"]).to have_received(:export).with("pipeline-a", "file-a.csv", "completed-data")
      expect(exporters["exporter_b"]).to have_received(:export).with("pipeline-b", "file-b.csv", "all-data")
    end
  end
end
