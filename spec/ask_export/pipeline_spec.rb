RSpec.describe AskExport::Pipeline do
  describe "#load_all" do
    it "returns pipeline object from config file" do
      config_path = File.join(__dir__, "..", "fixtures", "pipelines_test.yml")

      pipelines = AskExport::Pipeline.load_all(config_path)
      expect(pipelines).to match_array([be_a(AskExport::Pipeline), be_a(AskExport::Pipeline)])
    end
  end

  describe "#initialize" do
    it "returns object with defaults" do
      pipeline = AskExport::Pipeline.new(name: "pipeline1")

      expect(pipeline.name).to eq("pipeline1")
      expect(pipeline.fields).to eq([])
      expect(pipeline.only_completed).to be(true)
      expect(pipeline.targets).to eq([])
    end

    it "returns object with fields as symbols" do
      pipeline = AskExport::Pipeline.new(name: "pipeline1", fields: %w[a b c])

      expect(pipeline.fields).to eq(%i[a b c])
    end

    it "returns object with only completed" do
      pipeline = AskExport::Pipeline.new(name: "pipeline1", only_completed: false)

      expect(pipeline.only_completed).to be(false)
    end

    it "returns object with targets" do
      pipeline = AskExport::Pipeline.new(name: "pipeline1", targets: %w[a b c])

      expect(pipeline.targets).to eq(%w[a b c])
    end
  end

  describe "#run" do
    let(:targets) do
      {
        "target_a" => spy("TargetA"),
        "target_b" => spy("TargetB"),
      }
    end

    before do
      allow(AskExport::Targets).to receive(:load_all).and_return(targets)

      @report_builder = instance_double("AskExport::ReportBuilder")

      allow(@report_builder).to receive(:build).with(only_completed: true).and_return(
        instance_double("AskExport::Report", filename: "file-a.csv", to_csv: "completed-data"),
      )
      allow(@report_builder).to receive(:build).with(only_completed: false).and_return(
        instance_double("AskExport::Report", filename: "file-b.csv", to_csv: "all-data"),
      )
    end

    it "calls the correct export target" do
      pipeline = AskExport::Pipeline.new(
        name: "pipeline-a",
        fields: %i[a b],
        only_completed: true,
        targets: %w[target_a target_b],
      )

      pipeline.run(@report_builder)

      expect(targets["target_a"]).to have_received(:export).with("pipeline-a", "file-a.csv", "completed-data")
      expect(targets["target_b"]).to have_received(:export).with("pipeline-a", "file-a.csv", "completed-data")
    end
  end
end
