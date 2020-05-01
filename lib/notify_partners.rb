require "notifications/client"

class NotifyPartners
  THIRD_PARTY_TEMPLATE_ID = "".freeze
  CABINET_OFFICE_TEMPLATE_ID = "".freeze

  def self.call(*args)
    new(*args).call
  end

  def initialize(start_time, until_time, responses_count)
    @start_time = start_time
    @until_time = until_time
    @responses_count = responses_count
  end

  def call
    send_third_party_emails
    send_cabinet_office_emails
  end

  private_class_method :new

private

  attr_reader :start_time, :until_time, :responses_count

  def send_third_party_emails
    ENV["THIRD_PARTY_EMAIL_RECIPIENTS"].to_s.split(", ").each do |address|
      client.send_email(email_address: address,
                        template_id: THIRD_PARTY_TEMPLATE_ID,
                        personalisation: personalisation)
    end
  end

  def send_cabinet_office_emails
    ENV["CABINET_OFFICE_EMAIL_RECIPIENTS"].to_s.split(", ").each do |address|
      client.send_email(email_address: address,
                        template_id: CABINET_OFFICE_TEMPLATE_ID,
                        personalisation: personalisation)
    end
  end

  def personalisation
    {
    }
  end

  def client
    @client ||= Notifications::Client.new(ENV.fetch("NOTIFY_API_KEY"))
  end
end
