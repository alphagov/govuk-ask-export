module GoogleCloudHelper
  def stub_dlp_client
    client = instance_double("Google::Cloud::Dlp::V2::DlpService::Client")
    allow(Google::Cloud::Dlp::V2::DlpService::Client).to receive(:new)
      .and_return(client)

    client
  end

  def expect_deidentify_to_called(client, original_values, new_values)
    expect(client).to receive(:deidentify_content).with(
      hash_including(
        parent: "projects/project-name/locations/global",
        deidentify_config: be_a(Hash),
        inspect_config: be_a(Hash),
        item: { table: {
          headers: [{ name: "text" }],
          rows: original_values.map do |value|
            { values: [{ string_value: value }] }
          end,
        } },
      ),
    ).and_return(
      double(
        item: double(
          table: double(
            rows: new_values.map do |value|
              double(values: [double(string_value: value)])
            end,
          ),
        ),
      ),
    )
  end
end
