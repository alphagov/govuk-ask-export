module AskExport
  class FileExport
    def self.call
      new.call
    end

    def initialize
      @report = Report.new
      @csv_builder = CsvBuilder.new(report)
    end

    def call
      files = {
        "cabinet-office" => { data: csv_builder.cabinet_office, path: output_path("cabinet-office") },
        "data-labs" => { data: csv_builder.data_labs, path: output_path("data-labs") },
        "performance-analyst" => { data: csv_builder.performance_analyst, path: output_path("performance-analyst") },
        "third-party" => { data: csv_builder.third_party, path: output_path("third-party") },
      }

      files.each { |_, file| File.write(file[:path], file[:data], mode: "w") }
      relative_paths = files.values.map { |file| relative_to_cwd(file[:path]) }

      puts "CSV files have been output to: #{relative_paths.join(', ')}"
      files
    end

    private_class_method :new

  private

    attr_reader :report, :csv_builder

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
