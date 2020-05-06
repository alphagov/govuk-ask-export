require "csv"
require "pathname"

module AskExport
  class CsvSplitter
    def self.call(*args)
      new(*args).call
    end

    def initialize(input_path)
      @input_path = input_path
    end

    def call
      responses = []
      CSV.foreach(input_path, headers: true, encoding: "bom|utf-8") do |row|
        next if row["UserID"].empty? || fetch_answer(row, :over_18_field_id) != "Yes"

        responses << present_response(row)
      end

      puts "There were #{responses.count} responses retrieved from the input CSV"

      OutputFileWriter.call(DailyReport.new(responses))
    end

  private

    attr_reader :input_path

    def present_response(row)
      {
        id: row["UserID"],
        submission_time: Time.zone.parse(row["Ended"]).iso8601,
        region: fetch_answer(row, :region_field_id),
        question: fetch_answer(row, :question_field_id),
        question_format: fetch_answer(row, :question_format_field_id),
        name: fetch_answer(row, :name_field_id),
        email: fetch_answer(row, :email_field_id),
        phone: fetch_answer(row, :phone_field_id),
      }
    end

    def fetch_answer(row, field_id)
      row["Q#{AskExport.config(field_id)}"]
    end
  end
end
