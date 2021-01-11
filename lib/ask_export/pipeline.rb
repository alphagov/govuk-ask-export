module AskExport
  class Pipeline
    attr_reader :name, :fields, :only_completed, :targets

    def self.load_all(config_path)
      pipelines = YAML.load_file(config_path).fetch("pipelines")
      pipelines.map do |name, config|
        new(name: name, **config.transform_keys(&:to_sym))
      end
    end

    def initialize(name:, fields: [], only_completed: true, targets: [])
      @name = name
      @fields = fields.map(&:to_sym)
      @only_completed = only_completed
      @targets = targets
    end

    def run(report_builder)
      report = report_builder.build(only_completed: only_completed)

      filename = report.filename(name, "csv")
      data = report.to_csv(fields)

      targets.each do |target_name|
        target = fetch_target(target_name)

        target.export(name, filename, data)
      end
    end

  private

    def fetch_target(name)
      target = Targets.load_all[name]
      raise "Export target #{name} not found" unless target

      target
    end
  end
end
