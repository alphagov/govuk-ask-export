require "aws-sdk-s3"

module AskExport
  class FileExport
    def self.call
      new.call
    end

    def initialize
      @report = Report.new
    end

    def call
      csv_builder = CsvBuilder.new(report)

      File.write(cabinet_office_path, csv_builder.cabinet_office, mode: "w")
      File.write(data_labs_path, csv_builder.data_labs, mode: "w")
      File.write(third_party_path, csv_builder.third_party, mode: "w")

      puts "CSV files have been output to #{relative_to_cwd(cabinet_office_path)}, " \
        "#{relative_to_cwd(data_labs_path)} and #{relative_to_cwd(third_party_path)}"
    end

    private_class_method :new

  private

    attr_reader :report

    def cabinet_office_path
      "#{output_directory}/#{report.filename_prefix}-cabinet-office.csv"
    end

    def data_labs_path
      "#{output_directory}/#{report.filename_prefix}-data-labs.csv"
    end

    def third_party_path
      "#{output_directory}/#{report.filename_prefix}-third-party.csv"
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
