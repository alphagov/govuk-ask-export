RSpec.describe AskExport::Exporters do
  describe "#load_all" do
    it "returns a hash containing all exporters" do
      expected_exporters = {}

      AskExport::Exporters.constants.each do |exporter|
        dummy_exporter = double(exporter.to_s)
        allow(AskExport::Exporters.const_get(exporter)).to receive(:new)
          .and_return(dummy_exporter)

        underscored_name = exporter.to_s
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .downcase

        expected_exporters[underscored_name] = dummy_exporter
      end

      exporters = AskExport::Exporters.load_all

      expect(exporters).to eq(expected_exporters)
    end
  end
end
