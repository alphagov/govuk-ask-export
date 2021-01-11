module AskExport
  class FileExport
    def self.call
      new.call
    end

    def initialize
      config_path = File.expand_path("../../config/pipelines.yml", __dir__)

      @pipelines = Pipeline.load_all(config_path)
      @targets = Targets.load_all
      @report_builder = ReportBuilder.new
    end

    def call
      @pipelines.each do |pipeline|
        report = @report_builder.build(only_completed: pipeline.only_completed)

        filename = report.filename(pipeline.name, "csv")
        data = report.to_csv(pipeline.fields)

        pipeline.destinations.each do |dest|
          target = fetch_target(dest)

          target.export(pipeline.name, filename, data)
        end
      end
    end
    private_class_method :new

  private

    def fetch_target(name)
      target = @targets[name]
      raise "Export target #{name} not found" unless target

      target
    end
  end
end
