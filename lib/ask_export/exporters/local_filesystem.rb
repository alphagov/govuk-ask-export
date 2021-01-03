module AskExport
  module Exporters
    class LocalFilesystem
      def export(pipeline_name, filename, data)
        filepath = "#{LocalFilesystem.output_directory}/#{filename}"

        File.write(filepath, data, mode: "w")

        puts "CSV file for #{pipeline_name} output to: #{filepath}"
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
