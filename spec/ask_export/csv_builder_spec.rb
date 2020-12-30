RSpec.describe AskExport::CsvBuilder do
  let(:responses) do
    [
      report_response(id: 1, region: "Scotland"),
      report_response(id: 2, status: "partial"),
      report_response(id: 3, status: "disqualified"),
    ]
  end

  describe "#build_csv" do
    it "returns a csv of all records formatted for a performance analyst" do
      csv = described_class.new.build_csv(responses, :submission_time, :status, :user_agent, :region)
      expect(csv).to eq(
        "submission_time,status,user_agent,region\n" \
        "01/05/2020 09:00:00,completed,NCSA Mosaic/3.0 (Windows 95),Scotland\n" \
        "01/05/2020 09:00:00,partial,NCSA Mosaic/3.0 (Windows 95),\n" \
        "01/05/2020 09:00:00,disqualified,NCSA Mosaic/3.0 (Windows 95),\n",
      )
    end
  end
end
