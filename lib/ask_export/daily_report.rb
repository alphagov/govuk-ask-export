module AskExport
  class DailyReport
    attr_reader :since_time, :until_time

    def initialize(responses = nil)
      now = Time.zone.now
      @since_time = now.advance(days: -1).change(hour: 10)
      @until_time = now.change(hour: 10)
      @responses = responses
    end

    def responses
      @responses ||= SurveyResponseFetcher.call(since_time, until_time)
    end
  end
end
