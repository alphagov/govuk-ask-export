require "csv"

module AskExport
  class Report
    def initialize(responses, start_time, end_time)
      @responses = responses
      @start_time = start_time
      @end_time = end_time
    end

    def to_csv(fields)
      CSV.generate do |csv|
        csv << fields
        @responses.each do |response|
          csv << fields.map { |field| response[field] }
        end
      end
    end

    def filename(recipient, ext)
      time_format = "%Y-%m-%d-%H%M"
      start_time = @start_time.strftime(time_format)
      end_time = @end_time.strftime(time_format)

      "#{start_time}-to-#{end_time}-#{recipient}.#{ext}"
    end
  end
end
