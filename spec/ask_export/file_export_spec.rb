RSpec.describe AskExport::FileExport do
  describe ".call" do
    before do
      allow(AskExport::Targets).to receive(:load_all).and_return(targets)
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

    let(:targets) do
      {
        "target_a" => spy("TargetA"),
        "target_b" => spy("TargetB"),
      }
    end

    let(:pipelines) do
      [
        instance_double(
          AskExport::Pipeline,
          name: "pipeline-a",
          fields: %i[a b],
          only_completed: true,
          targets: %w[target_a],
        ),
        instance_double(
          AskExport::Pipeline,
          name: "pipeline-b",
          fields: %i[x y],
          only_completed: false,
          targets: %w[target_b],
        ),
      ]
    end

    it "calls export on all the targets defined in the pipelines" do
      described_class.call

      expect(targets["target_a"]).to have_received(:export).with("pipeline-a", "file-a.csv", "completed-data")
      expect(targets["target_b"]).to have_received(:export).with("pipeline-b", "file-b.csv", "all-data")
    end
  end
end
