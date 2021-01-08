RSpec.describe AskExport::Transformers::Deidentify do
  describe "#bulk_transform" do
    it "makes calls to Google Cloud DLP" do
      client = stub_dlp_client

      expect_deidentify_to_called(client, %w[a b c d], %w[a x x d])

      ClimateControl.modify GOOGLE_CLOUD_PROJECT: "project-name" do
        transformer = described_class.new

        transformed_values = transformer.bulk_transform(%w[a b c d])

        expect(transformed_values).to eq(%w[a x x d])
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
        transformer = described_class.new

        transformed_values = transformer.bulk_transform(original_values)

        expect(transformed_values).to eq(expected_values)
      end
    end
  end
end
