require "notifications/client"

module AskExport
  class PartnerNotifier
    CABINET_OFFICE_TEMPLATE_ID = "4f81afc5-c018-4305-ad1e-b722189d4a10".freeze
    DATA_LABS_TEMPLATE_ID = "53f2afe6-e9cc-455f-847b-c2f02ba8d485".freeze
    PERFORMANCE_ANALYST_TEMPLATE_ID = "3b4194c3-4e4a-4ebc-8cc5-c81c3613fb30".freeze
    THIRD_PARTY_TEMPLATE_ID = "959ac4b4-b640-459e-a037-981a3049d55b".freeze

    def self.call(*args)
      new(*args).call
    end

    def initialize(report)
      @client = Notifications::Client.new(ENV.fetch("NOTIFY_API_KEY"))
      @report = report
    end

    def call
      send_emails(ENV.fetch("CABINET_OFFICE_EMAIL_RECIPIENTS"),
                  CABINET_OFFICE_TEMPLATE_ID)
      send_emails(ENV.fetch("DATA_LABS_EMAIL_RECIPIENTS"),
                  DATA_LABS_TEMPLATE_ID)
      send_emails(ENV.fetch("PERFORMANCE_ANALYST_EMAIL_RECIPIENTS"),
                  PERFORMANCE_ANALYST_TEMPLATE_ID)
      send_emails(ENV.fetch("THIRD_PARTY_EMAIL_RECIPIENTS"),
                  THIRD_PARTY_TEMPLATE_ID)
    end

    private_class_method :new

  private

    attr_reader :client, :report

    def send_emails(addresses, template_id)
      addresses.split(",").each do |address|
        client.send_email(email_address: address.strip,
                          template_id: template_id,
                          personalisation: personalisation)
      end
    end

    def personalisation
      time_formatting = "%-l:%M%P on %-d %B %Y"
      {
        since_time: report.since_time.strftime(time_formatting),
        until_time: report.until_time.strftime(time_formatting),
        completed_responses_count: report.completed_responses.count,
        all_responses_count: report.responses.count,
      }
    end
  end
end
