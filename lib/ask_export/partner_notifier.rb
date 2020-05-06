require "notifications/client"

module AskExport
  class PartnerNotifier
    CABINET_OFFICE_TEMPLATE_ID = "4f81afc5-c018-4305-ad1e-b722189d4a10".freeze
    THIRD_PARTY_TEMPLATE_ID = "959ac4b4-b640-459e-a037-981a3049d55b".freeze

    def self.call(*args)
      new(*args).call
    end

    def initialize(since_time, until_time, responses_count)
      @client = Notifications::Client.new(ENV.fetch("NOTIFY_API_KEY"))
      @since_time = since_time
      @until_time = until_time
      @responses_count = responses_count
    end

    def call
      send_cabinet_office_emails
      send_third_party_emails
    end

    private_class_method :new

  private

    attr_reader :client, :since_time, :until_time, :responses_count

    def send_cabinet_office_emails
      ENV.fetch("CABINET_OFFICE_EMAIL_RECIPIENTS").split(",").each do |address|
        client.send_email(email_address: address.strip,
                          template_id: CABINET_OFFICE_TEMPLATE_ID,
                          personalisation: personalisation)
      end
    end

    def send_third_party_emails
      ENV.fetch("THIRD_PARTY_EMAIL_RECIPIENTS").split(",").each do |address|
        client.send_email(email_address: address.strip,
                          template_id: THIRD_PARTY_TEMPLATE_ID,
                          personalisation: personalisation)
      end
    end

    def personalisation
      time_formatting = "%-l:%M%P on %-d %B %Y"
      {
        since_time: since_time.strftime(time_formatting),
        until_time: until_time.strftime(time_formatting),
        responses_count: responses_count,
      }
    end
  end
end
