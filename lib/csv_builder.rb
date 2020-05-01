require "csv"

class CsvBuilder
  def initialize(responses)
    @responses = responses
  end

  def third_party
    build_csv("third_party",
              :id,
              :submission_time,
              :region,
              :question,
              :question_format)
  end

  def cabinet_office
    build_csv("cabinet_office",
              :id,
              :submission_time,
              :region,
              :name,
              :email,
              :phone,
              :question_format)
  end

private

  attr_reader :responses

  def build_csv(name, *fields)
    CSV.generate do |csv|
      csv << responses.first.slice(*fields).keys
      responses.each { |row| csv << row.slice(*fields).values }
    end
  end
end
