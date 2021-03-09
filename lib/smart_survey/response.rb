module SmartSurvey
  class Response
    def self.parse(response)
      questions = response[:pages].flat_map { |page| page[:questions] }
      answers = questions.each_with_object({}) do |question, hash|
        answer = question[:answers]&.first
        hash[question[:id]] = answer.fetch(:value, answer[:choice_title])
      end

      variables = response.fetch(:variables, []).each_with_object({}) do |variable, memo|
        memo[variable[:name]] = variable[:value]
      end

      new(
        id: response[:id],
        status: response[:status],
        started: Time.zone.iso8601(response[:date_started]),
        ended: Time.zone.iso8601(response[:date_ended]),
        answers: answers,
        variables: variables,
      )
    end

    attr_reader :id, :status, :started, :ended, :answers, :variables

    def initialize(id:, status:, started:, ended:, answers:, variables:)
      @id = id
      @status = status
      @started = started
      @ended = ended
      @answers = answers
      @variables = variables
    end

    def completed?
      @status == "completed"
    end
  end
end
