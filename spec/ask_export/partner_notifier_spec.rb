RSpec.describe AskExport::PartnerNotifier do
  describe ".call" do
    around do |example|
      ClimateControl.modify(
        NOTIFY_API_KEY: "secret",
        CABINET_OFFICE_EMAIL_RECIPIENTS: cabinet_office_emails,
        THIRD_PARTY_EMAIL_RECIPIENTS: third_party_emails,
      ) { example.run }
    end

    around do |example|
      travel_to(Time.zone.parse("2020-05-01 10:00")) { example.run }
    end

    before do
      allow(Notifications::Client).to receive(:new).and_return(notify_client)
    end

    let(:notify_client) do
      instance_double(Notifications::Client, send_email: true)
    end

    let(:cabinet_office_emails) do
      "person1@cabinet-office.example.com, person2@cabinet-office.example.com"
    end

    let(:third_party_emails) do
      "person1@third-party.example.com, person2@third-party.example.com"
    end

    let(:report) do
      stubbed_report(responses: [presented_survey_response,
                                 presented_survey_response])
    end

    let(:personalisation) do
      {
        since_time: "10:00am on 30 April 2020",
        until_time: "10:00am on 1 May 2020",
        responses_count: 2,
      }
    end

    it "sends emails to cabinet office recipients" do
      described_class.call(report)
      expect(notify_client)
        .to have_received(:send_email)
        .with(email_address: "person1@cabinet-office.example.com",
              template_id: described_class::CABINET_OFFICE_TEMPLATE_ID,
              personalisation: personalisation)
      expect(notify_client)
        .to have_received(:send_email)
        .with(email_address: "person2@cabinet-office.example.com",
              template_id: described_class::CABINET_OFFICE_TEMPLATE_ID,
              personalisation: personalisation)
    end

    it "sends emails to third party recipients" do
      described_class.call(report)
      expect(notify_client)
        .to have_received(:send_email)
        .with(email_address: "person1@third-party.example.com",
              template_id: described_class::THIRD_PARTY_TEMPLATE_ID,
              personalisation: personalisation)
      expect(notify_client)
        .to have_received(:send_email)
        .with(email_address: "person2@third-party.example.com",
              template_id: described_class::THIRD_PARTY_TEMPLATE_ID,
              personalisation: personalisation)
    end
  end
end
