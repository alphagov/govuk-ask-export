require "aws-sdk-s3"

module AskExport
  class S3Export
    def self.call
      new.call
    end

    def initialize
      @daily_report = DailyReport.new
    end

    def call
      csv_builder = CsvBuilder.new(daily_report.responses)

      upload_to_s3("cabinet-office/#{daily_report.until_time.to_date}.csv", csv_builder.cabinet_office)
      upload_to_s3("third-party/#{daily_report.until_time.to_date}.csv", csv_builder.third_party)

      puts "Files uploaded to S3"

      PartnerNotifier.call(daily_report.since_time,
                           daily_report.until_time,
                           daily_report.responses.count)

      puts "Partners have been notified"
    end

    private_class_method :new

  private

    attr_reader :daily_report

    def upload_to_s3(key, data)
      client = Aws::S3::Resource.new.client
      client.put_object(bucket: ENV.fetch("S3_BUCKET"),
                        key: ENV.fetch("S3_PATH_PREFIX", "") + key,
                        body: data)
    end
  end
end
