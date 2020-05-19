module AskExport
  class DriveExport
    READABLE_TIME_FORMAT = "%-l:%M%P on %-d %B %Y".freeze

    def self.call
      new.call
    end

    def initialize
      @report = Report.new
      @file_distributor = FileDistributor.new
      @csv_builder = CsvBuilder.new(report)
    end

    def call
      distribute_cabinet_office_csv
      distribute_data_labs_csv
      distribute_performance_analyst_csv
      distribute_third_party_csv

      puts "All files uploaded to Google Drive and shared with partners"
    end

    private_class_method :new

  private

    attr_reader :report, :csv_builder, :file_distributor

    def distribute_cabinet_office_csv
      file = file_distributor.upload_csv("#{report.filename_prefix}-cabinet-office.csv",
                                         csv_builder.cabinet_office,
                                         ENV.fetch("CABINET_OFFICE_DRIVE_FOLDER"))

      file_distributor.share_file(
        file.id,
        recipients_from_env_var("CABINET_OFFICE_RECIPIENTS"),
        notification_personalisation.merge(audience: "the Cabinet Office"),
      )
    end

    def distribute_data_labs_csv
      file = file_distributor.upload_csv("#{report.filename_prefix}-data-labs.csv",
                                         csv_builder.data_labs,
                                         ENV.fetch("DATA_LABS_DRIVE_FOLDER"))

      file_distributor.share_file(
        file.id,
        recipients_from_env_var("DATA_LABS_RECIPIENTS"),
        notification_personalisation.merge(audience: "GOV.UK Data Labs"),
      )
    end

    def distribute_performance_analyst_csv
      file = file_distributor.upload_csv("#{report.filename_prefix}-performance-analyst.csv",
                                         csv_builder.performance_analyst,
                                         ENV.fetch("PERFORMANCE_ANALYST_DRIVE_FOLDER"))

      file_distributor.share_file(
        file.id,
        recipients_from_env_var("PERFORMANCE_ANALYST_RECIPIENTS"),
        notification_personalisation.merge(audience: "GOV.UK performance analysis",
                                           responses_count: report.responses.count),
      )
    end

    def distribute_third_party_csv
      file = file_distributor.upload_csv("#{report.filename_prefix}-third-party.csv",
                                         csv_builder.third_party,
                                         ENV.fetch("THIRD_PARTY_DRIVE_FOLDER"))

      file_distributor.share_file(
        file.id,
        recipients_from_env_var("THIRD_PARTY_RECIPIENTS"),
        notification_personalisation.merge(audience: "a third party polling organisation"),
      )
    end

    def notification_personalisation
      {
        since_time: report.since_time.strftime(READABLE_TIME_FORMAT),
        until_time: report.until_time.strftime(READABLE_TIME_FORMAT),
        responses_count: report.completed_responses.count,
      }
    end

    def recipients_from_env_var(name)
      ENV.fetch(name).split(",").map(&:strip)
    end
  end
end
