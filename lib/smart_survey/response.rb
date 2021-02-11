module SmartSurvey
  class Response
    def self.parse(response)
      questions = response[:pages].flat_map { |page| page[:questions] }
      answers = questions.each_with_object({}) do |question, hash|
        answer = question[:answers]&.first
        hash[question[:id]] = answer.fetch(:value, answer[:choice_title])
      end

      new(
        id: response[:id],
        status: response[:status],
        started: Time.zone.iso8601(response[:date_started]),
        ended: Time.zone.iso8601(response[:date_ended]),
        answers: answers,
      )
    end

    attr_reader :id, :status, :started, :ended, :answers

    def initialize(id:, status:, started:, ended:, answers:)
      @id = id
      @status = status
      @started = started
      @ended = ended
      @answers = answers
    end

    def completed?
      @status == "completed"
    end
  end
end
