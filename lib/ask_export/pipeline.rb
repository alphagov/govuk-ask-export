module AskExport
  class Pipeline
    attr_reader :name, :fields, :only_completed, :destinations

    def self.load_all(config_path)
      pipelines = YAML.load_file(config_path).fetch("pipelines")
      pipelines.map do |name, config|
        new(name: name, **config.transform_keys(&:to_sym))
      end
    end

    def initialize(name:, fields: [], only_completed: true, destinations: [])
      @name = name
      @fields = fields.map(&:to_sym)
      @only_completed = only_completed
      @destinations = destinations
    end
  end
end
