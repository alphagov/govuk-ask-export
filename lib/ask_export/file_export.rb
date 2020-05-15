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

      files = {
        output_path("cabinet-office") => csv_builder.cabinet_office,
        output_path("data-labs") => csv_builder.data_labs,
        output_path("performance-analyst") => csv_builder.performance_analyst,
        output_path("third-party") => csv_builder.third_party,
      }

      files.each { |path, data| File.write(path, data, mode: "w") }
      relative_paths = files.keys.map { |path| relative_to_cwd(path) }

      puts "CSV files have been output to: #{relative_paths.join(', ')}"
    end

    private_class_method :new

  private

    attr_reader :report

    def output_path(recipient)
      "#{output_directory}/#{report.filename_prefix}-#{recipient}.csv"
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
