module AskExport
  class Runner
    def self.call
      new.call
    end

    def initialize
      now = Time.zone.now
      @since_time = now.advance(days: -1).change(hour: 10)
      @until_time = now.change(hour: 10)
    end

    def call
      raise "Too early, submissions for today are still open" if until_time > Time.zone.now

      responses = SurveyResponseFetcher.call(since_time, until_time) do |progress|
        puts "downloaded #{progress} responses"
      end

      puts "#{responses.count} total responses from #{since_time} until #{until_time}"
    end

    private_class_method :new

  private

    attr_reader :since_time, :until_time
  end
end
