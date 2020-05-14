module AskExport
  class DriveExport
    def self.call
      new.call
    end

    def initialize
      @report = Report.new
      @drive_uploader = DriveUploader.new
      @csv_builder = CsvBuilder.new(report)
    end

    def call
      upload_cabinet_office_csv
      upload_data_labs_csv
      upload_performance_analyst_csv
      upload_third_party_csv

      puts "All files uploaded to Google Drive"
    end

    private_class_method :new

  private

    attr_reader :report, :csv_builder, :drive_uploader

    def upload_cabinet_office_csv
      file = drive_uploader.upload_csv("#{report.filename_prefix}-cabinet-office.csv",
                                       csv_builder.cabinet_office,
                                       ENV.fetch("CABINET_OFFICE_DRIVE_FOLDER"))

      drive_uploader.share_file(
        file.id,
        recipients_from_env_var("CABINET_OFFICE_RECIPIENTS"),
      )
    end

    def upload_data_labs_csv
      file = drive_uploader.upload_csv("#{report.filename_prefix}-data-labs.csv",
                                       csv_builder.data_labs,
                                       ENV.fetch("DATA_LABS_DRIVE_FOLDER"))

      drive_uploader.share_file(
        file.id,
        recipients_from_env_var("DATA_LABS_RECIPIENTS"),
      )
    end

    def upload_performance_analyst_csv
      file = drive_uploader.upload_csv("#{report.filename_prefix}-performance-analyst.csv",
                                       csv_builder.performance_analyst,
                                       ENV.fetch("PERFORMANCE_ANALYST_DRIVE_FOLDER"))

      drive_uploader.share_file(
        file.id,
        recipients_from_env_var("PERFORMANCE_ANALYST_RECIPIENTS"),
      )
    end

    def upload_third_party_csv
      file = drive_uploader.upload_csv("#{report.filename_prefix}-third-party.csv",
                                       csv_builder.third_party,
                                       ENV.fetch("THIRD_PARTY_DRIVE_FOLDER"))

      drive_uploader.share_file(
        file.id,
        recipients_from_env_var("THIRD_PARTY_RECIPIENTS"),
      )
    end

    def recipients_from_env_var(name)
      ENV.fetch(name).split(",").map(&:strip)
    end
  end
end
