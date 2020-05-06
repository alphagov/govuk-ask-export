RSpec.describe AskExport::CsvBuilder do
  let(:responses) do
    [
      presented_survey_response(id: 1, region: "Scotland"),
      presented_survey_response(id: 2, region: "Yorkshire and the Humber"),
    ]
  end

  describe "#cabinet_office" do
    context "when there are no responses" do
      it "returns a csv string of the headers" do
        builder = described_class.new([])
        expect(builder.cabinet_office)
          .to eq("id,submission_time,region,name,email,phone,question_format\n")
      end
    end

    context "when there are responses" do
      it "returns a csv of cabinet office data" do
        builder = described_class.new(responses)
        expect(builder.cabinet_office).to eq(
          "id,submission_time,region,name,email,phone,question_format\n" \
          "1,2020-05-01T09:00:00+01:00,Scotland,Jane Doe,jane@example.com,+447123456789,\"In writing, to be read out at the press conference\"\n" \
          "2,2020-05-01T09:00:00+01:00,Yorkshire and the Humber,Jane Doe,jane@example.com,+447123456789,\"In writing, to be read out at the press conference\"\n",
        )
      end
    end
  end

  describe "#third_party" do
    context "when there are no responses" do
      it "returns a csv string of the headers" do
        builder = described_class.new([])
        expect(builder.third_party)
          .to eq("id,submission_time,region,question,question_format\n")
      end
    end

    context "when there are responses" do
      it "returns a csv of cabinet office data" do
        builder = described_class.new(responses)
        expect(builder.third_party).to eq(
          "id,submission_time,region,question,question_format\n" \
          "1,2020-05-01T09:00:00+01:00,Scotland,A question?,\"In writing, to be read out at the press conference\"\n" \
          "2,2020-05-01T09:00:00+01:00,Yorkshire and the Humber,A question?,\"In writing, to be read out at the press conference\"\n",
        )
      end
    end
  end
end
