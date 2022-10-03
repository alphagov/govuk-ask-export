module AskExport
  module Targets
    ALL = {
      "google_drive" => GoogleDrive,
      "filesystem" => Filesystem,
    }.freeze

    @target_cache = {}

    def self.find(name)
      @target_cache[name] ||= begin
        target_class = ALL[name]
        target = target_class.new if target_class

        raise "Export target #{name} not found" unless target

        target
      end
    end

    def self.clear_cache
      @target_cache = {}
    end
  end
end
