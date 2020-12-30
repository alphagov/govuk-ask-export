module AskExport
  class FileExport
    def self.call
      new.call
    end

    def initialize
      config_path = File.expand_path("../../config/pipelines.yml", __dir__)

      @pipelines = Pipeline.load_all(config_path)
      @report = Report.new
      @csv_builder = CsvBuilder.new
    end

    def call
      files = {}

      @pipelines.each do |pipeline|
        responses = if pipeline.only_completed
                      @report.completed_responses
                    else
                      @report.responses
                    end

        data = csv_builder.build_csv(responses, *pipeline.fields)
        filepath = output_path(pipeline.name)

        File.write(filepath, data, mode: "w")

        puts "CSV file for #{pipeline.name} output to: #{filepath}"

        files[pipeline.name] = { path: filepath }
      end

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
