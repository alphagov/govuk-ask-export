module AskExport
  module Exporters
    def self.load_all
      {
        "google_drive" => GoogleDrive.new,
        "local_filesystem" => LocalFilesystem.new,
      }
    end
  end
end
