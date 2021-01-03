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
      expect(pipeline.destinations).to eq([])
    end

    it "returns object with fields as symbols" do
      pipeline = AskExport::Pipeline.new(name: "pipeline1", fields: %w[a b c])

      expect(pipeline.fields).to eq(%i[a b c])
    end

    it "returns object with only completed" do
      pipeline = AskExport::Pipeline.new(name: "pipeline1", only_completed: false)

      expect(pipeline.only_completed).to be(false)
    end

    it "returns object with destinations" do
      pipeline = AskExport::Pipeline.new(name: "pipeline1", destinations: %w[a b c])

      expect(pipeline.destinations).to eq(%w[a b c])
    end
  end
end
