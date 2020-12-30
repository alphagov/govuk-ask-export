require "csv"

module AskExport
  class CsvBuilder
    def build_csv(responses, *fields)
      CSV.generate do |csv|
        csv << fields
        responses.each do |response|
          csv << fields.map { |field| response[field] }
        end
      end
    end
  end
end
