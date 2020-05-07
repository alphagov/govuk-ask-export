module AskExport
  class Report
    attr_reader :since_time, :until_time

    def initialize
      now = Time.zone.now
      @since_time = now.advance(days: -1).change(hour: 10)
      @until_time = now.change(hour: 10)
    end

    def responses
      @responses ||= SurveyResponseFetcher.call(since_time, until_time)
    end

    def filename_prefix
      time_format = "%Y-%m-%d-%H%M"
      "#{since_time.strftime(time_format)}-to-#{until_time.strftime(time_format)}"
    end
  end
end
