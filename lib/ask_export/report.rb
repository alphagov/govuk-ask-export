module AskExport
  class Report
    def since_time
      @since_time ||= parse_time(ENV.fetch("SINCE_TIME", "10:00"),
                                 relative_to: Date.yesterday)
    end

    def until_time
      @until_time ||= parse_time(ENV.fetch("UNTIL_TIME", "10:00"),
                                 relative_to: Date.current)
    end

    def responses
      @responses ||= SurveyResponseFetcher.call(since_time, until_time)
    end

    def filename_prefix
      time_format = "%Y-%m-%d-%H%M"
      "#{since_time.strftime(time_format)}-to-#{until_time.strftime(time_format)}"
    end

  private

    def parse_time(time, relative_to:)
      Time.zone.parse(time, relative_to).tap do |parsed|
        message = %("#{time}" could not be parsed as a time)
        raise ArgumentError, message unless parsed
      end
    end
  end
end
