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
        next if row["UserID"].empty?

        responses << present_response(row)
      end

      puts "There were #{responses.count} responses retrieved from the input CSV"

      builder = CsvBuilder.new(responses)
      File.write(cabinet_office_path, builder.cabinet_office, mode: "w")
      File.write(third_party_path, builder.third_party, mode: "w")

      puts "CSV files have been output to #{relative_to_cwd(cabinet_office_path)} " \
        "and #{relative_to_cwd(third_party_path)}"
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

    def cabinet_office_path
      "#{output_directory}/#{Date.current}-cabinet-office.csv"
    end

    def third_party_path
      "#{output_directory}/#{Date.current}-third-party.csv"
    end

    def output_directory
      ENV.fetch(
        "OUTPUT_DIR",
        File.expand_path("../../output", __dir__),
      )
    end

    def relative_to_cwd(path)
      Pathname.new(path).relative_path_from(Pathname.new(Dir.pwd))
    end
  end
end
