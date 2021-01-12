RSpec.describe AskExport::Targets do
  describe "#find" do
    let(:target_a1) { double("target_al") }
    let(:target_b1) { double("target_bl") }

    before do
      target_classes = {
        "target_a" => double("TargetA"),
        "target_b" => double("TargetB"),
      }

      allow(target_classes["target_a"]).to receive(:new)
        .and_return(target_a1, double("target_a2"))

      allow(target_classes["target_b"]).to receive(:new)
        .and_return(target_b1, double("target_b2"))

      stub_const("AskExport::Targets::ALL", target_classes)
    end

    it "returns the named target object" do
      target = AskExport::Targets.find("target_a")

      expect(target).to eq(target_a1)
    end

    it "returns the same named target object on multiple calls" do
      AskExport::Targets.find("target_b")
      target = AskExport::Targets.find("target_b")

      expect(target).to eq(target_b1)
    end

    it "raises a error if target not available" do
      expect { AskExport::Targets.find("target_c") }
        .to raise_error("Export target target_c not found")
    end
  end
end
