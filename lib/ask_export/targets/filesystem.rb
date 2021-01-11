module AskExport
  module Targets
    class Filesystem
      def export(_pipeline_name, filename, data)
        filepath = "#{Filesystem.output_directory}/#{filename}"

        File.write(filepath, data, mode: "w")

        puts "File export: file saved to #{filepath}"
      end

      def self.output_directory
        ENV.fetch(
          "OUTPUT_DIR",
          File.expand_path("../../../output", __dir__),
        )
      end
    end
  end
end
