RSpec.describe AskExport::Targets do
  describe "#load_all" do
    it "returns a hash containing all targets" do
      expected_targets = {}

      AskExport::Targets.constants.each do |target|
        dummy_target = double(target.to_s)
        allow(AskExport::Targets.const_get(target)).to receive(:new)
          .and_return(dummy_target)

        underscored_name = target.to_s
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .downcase

        expected_targets[underscored_name] = dummy_target
      end

      targets = AskExport::Targets.load_all

      expect(targets).to eq(expected_targets)
    end
  end
end
