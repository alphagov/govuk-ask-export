RSpec.describe AskExport::Deidentifier do
  describe "#bulk_deidentify" do
    it "makes calls to Google Cloud DLP" do
      client = stub_dlp_client

      expect_deidentify_to_called(client, %w[a b c d], %w[a x x d])

      ClimateControl.modify GOOGLE_CLOUD_PROJECT: "project-name" do
        deidentifier = described_class.new

        deidentified_values = deidentifier.bulk_deidentify(%w[a b c d])

        expect(deidentified_values).to eq(%w[a x x d])
      end
    end

    it "makes multiple calls to Google Cloud DLP if many values" do
      client = stub_dlp_client

      original_values = %w[a] * 500 + %w[b] * 500 + %w[c] * 200
      expected_values = %w[a] * 500 + %w[x] * 500 + %w[c] * 200

      expect_deidentify_to_called(client, %w[a] * 500, %w[a] * 500)
      expect_deidentify_to_called(client, %w[b] * 500, %w[x] * 500)
      expect_deidentify_to_called(client, %w[c] * 200, %w[c] * 200)

      ClimateControl.modify GOOGLE_CLOUD_PROJECT: "project-name" do
        deidentifier = described_class.new

        deidentified_values = deidentifier.bulk_deidentify(original_values)

        expect(deidentified_values).to eq(expected_values)
      end
    end
  end
end
