require "faraday"
require "json"

module AskExport
  class SurveyResponseFetcher
    RESPONSES_PER_REQUEST = 100

    def self.call(*args)
      new(*args).call
    end

    def initialize(since_time, until_time)
      @since_time = since_time
      @until_time = until_time
    end

    def call
      if since_time >= until_time
        raise ArgumentError, "Export since time must be before the until time"
      end

      if until_time > Time.zone.now
        raise ArgumentError, "You are requesting an export for future data"
      end

      puts "Requesting responses from #{since_time} until #{until_time}"

      page = 1
      responses = []
      loop do
        body = JSON.parse(request_responses(page).body, symbolize_names: true)

        responses += body.map { |entry| ResponseSerialiser.call(entry) }

        puts "downloaded #{responses.count} responses"

        break if body.length < RESPONSES_PER_REQUEST

        # We're rate limited to 180 requests a minute so we need to slow
        # our requests down a bit
        sleep 0.33
        page += 1
      end

      completed = responses.count { |r| r[:status] == "completed" }
      puts "#{responses.count} total responses, #{completed} completed responses"
      responses
    end

    private_class_method :new

  private

    attr_reader :since_time, :until_time

    def request_responses(page)
      survey_id = AskExport.config(:survey_id)
      http_client.get("surveys/#{survey_id}/responses",
                      page: page,
                      page_size: RESPONSES_PER_REQUEST,
                      since: since_time.to_i,
                      until: until_time.to_i,
                      sort_by: "date_ended,asc",
                      include_labels: true,
                      # include both partial and completed responses
                      completed: 2)
    end

    def http_client
      @http_client ||= Faraday.new(
        "https://api.smartsurvey.io/v1/",
        params: {
          api_token: ENV.fetch("SMART_SURVEY_API_TOKEN"),
          api_token_secret: ENV.fetch("SMART_SURVEY_API_TOKEN_SECRET"),
        },
      ) do |f|
        interval = 20

        retry_if = ->(env, exception) do
          if env.status.nil?
            puts "Request failed with #{exception.inspect}, retrying in #{interval} seconds"
            true
          elsif env.status == 429 || env.status >= 500
            puts "Received a #{env.status} response, retrying in #{interval} seconds"
            true
          end
        end

        f.request(:retry,
                  max: 3,
                  interval: interval,
                  exceptions: [Faraday::Error],
                  methods: [], # has to be empty for the retry_if to execute
                  retry_if: retry_if)
        f.response(:raise_error)
      end
    end
  end
end
