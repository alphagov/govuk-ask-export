RSpec.describe AskExport::CsvBuilder do
  let(:responses) do
    [
      presented_survey_response(id: 1, region: "Scotland"),
      presented_survey_response(id: 2, status: "partial"),
      presented_survey_response(id: 3, status: "disqualified", client_id: 100),
    ]
  end
  let(:builder) { described_class.new(stubbed_report(responses: responses)) }

  describe "#cabinet_office" do
    it "returns a csv of completed records formatted for cabinet office" do
      expect(builder.cabinet_office).to eq(
        "id,submission_time,region,name,email,phone,question_format\n" \
        "1,01/05/2020 09:00:00,Scotland,Jane Doe,jane@example.com,+447123456789,\"In writing, to be read out at the press conference\"\n",
      )
    end
  end

  describe "#data_labs" do
    let(:secret_key) { SecureRandom.uuid }
    let(:hashed_email) { Digest::SHA256.hexdigest("jane@example.com" + secret_key) }
    let(:hashed_phone) { Digest::SHA256.hexdigest("+447123456789" + secret_key) }

    it "returns a csv of completed records with hashed emails and phone numbers for Data Labs" do
      ClimateControl.modify(SECRET_KEY: secret_key) do
        expect(builder.data_labs).to eq(
          "submission_time,region,question,question_format,hashed_email,hashed_phone\n" \
          "01/05/2020 09:00:00,Scotland,A question?,\"In writing, to be read out at the press conference\",#{hashed_email},#{hashed_phone}\n",
        )
      end
    end
  end

  describe "#performance_analyst" do
    it "returns a csv of all records formatted for a performance analyst" do
      expect(builder.performance_analyst).to eq(
        "start_time,submission_time,status,user_agent,client_id,region\n" \
        "01/05/2020 08:55:00,01/05/2020 09:00:00,completed,NCSA Mosaic/3.0 (Windows 95),,Scotland\n" \
        "01/05/2020 08:55:00,01/05/2020 09:00:00,partial,NCSA Mosaic/3.0 (Windows 95),,\n" \
        "01/05/2020 08:55:00,01/05/2020 09:00:00,disqualified,NCSA Mosaic/3.0 (Windows 95),100,\n",
      )
    end
  end

  describe "#third_party" do
    it "returns a csv of completed records formatted for a third party" do
      expect(builder.third_party).to eq(
        "id,submission_time,region,question,question_format\n" \
        "1,01/05/2020 09:00:00,Scotland,A question?,\"In writing, to be read out at the press conference\"\n",
      )
    end
  end
end
