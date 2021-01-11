RSpec.describe AskExport::Report do
  let(:responses) do
    [
      report_response(id: 1, region: "Scotland"),
      report_response(id: 2, status: "partial"),
      report_response(id: 3, status: "disqualified"),
    ]
  end

  describe "#to_csv" do
    it "returns the responses formatted as a CSV" do
      report = described_class.new(responses, nil, nil)
      fields = %i[end_time status user_agent region]

      expect(report.to_csv(fields)).to eq(
        "end_time,status,user_agent,region\n" \
        "2020-05-01 09:00:00 +0100,completed,NCSA Mosaic/3.0 (Windows 95),Scotland\n" \
        "2020-05-01 09:00:00 +0100,partial,NCSA Mosaic/3.0 (Windows 95),\n" \
        "2020-05-01 09:00:00 +0100,disqualified,NCSA Mosaic/3.0 (Windows 95),\n",
      )
    end
  end

  describe "#filename" do
    it "returns a string with the time range, recipient and extension" do
      report = described_class.new(
        [],
        Time.new(2020, 4, 30, 10, 0),
        Time.new(2020, 5, 1, 10, 0),
      )

      expect(report.filename("recipient", "ext"))
        .to eq("2020-04-30-1000-to-2020-05-01-1000-recipient.ext")
    end
  end
end
