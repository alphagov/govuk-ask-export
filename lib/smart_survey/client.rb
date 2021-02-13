require "faraday"
require "json"

module SmartSurvey
  class Client
    BASE_URL = "https://api.smartsurvey.io/v1/".freeze
    PAGE_SIZE = 100

    def initialize
      credentials = { api_token: api_token, api_token_secret: api_token_secret }
      @conn = Faraday.new(BASE_URL, params: credentials) do |f|
        retry_options = {
          max: 3,
          interval: 1,
          interval_randomness: 0.5,
          backoff_factor: 2,
          retry_statuses: [401, 409, 408, 429, 500, 501, 502, 503, 504],
        }

        f.request(:retry, retry_options)
        f.response(:raise_error)
      end
    end

    def list_responses(survey_id:, response_class: SmartSurvey::Response, **options)
      since_time = options[:since_time]
      until_time = options[:until_time]

      msg = "Requesting responses"
      msg += " from #{since_time}" if since_time
      msg += " to #{until_time}" if until_time
      puts msg

      params = {
        page_size: PAGE_SIZE,
        since: since_time&.to_i,
        until: until_time&.to_i,
        sort_by: "date_ended,asc",
        include_labels: options.fetch(:include_labels, true),
        completed: options.fetch(:completed, 2),
      }.compact

      responses = paginated_get("surveys/#{survey_id}/responses", **params).to_a.flatten
      responses = responses.map { |response| response_class.parse(response) }

      completed = responses.count(&:completed?)
      puts "#{responses.count} total responses, #{completed} completed responses"
      responses
    end

    def delete_response(survey_id:, response_id:)
      @conn.delete("surveys/#{survey_id}/responses/#{response_id}")
    end

  private

    def api_token
      ENV["SMART_SURVEY_API_TOKEN"]
    end

    def api_token_secret
      ENV["SMART_SURVEY_API_TOKEN_SECRET"]
    end

    def paginated_get(path, params = {})
      Enumerator.new do |y|
        params = params.dup
        page = 1

        loop do
          response = @conn.get(path, params.merge(page: page))
          data = JSON.parse(response.body, symbolize_names: true)
          y.yield data

          break if data.length < PAGE_SIZE

          # We're rate limited to 180 requests a minute so we need to slow
          # our requests down a bit
          sleep 0.33
          page += 1
        end
      end
    end
  end
end
