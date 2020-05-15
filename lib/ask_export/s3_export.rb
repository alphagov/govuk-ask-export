require "aws-sdk-s3"

module AskExport
  class S3Export
    def self.call
      new.call
    end

    def initialize
      @report = Report.new
    end

    def call
      csv_builder = CsvBuilder.new(report)

      {
        output_key("cabinet-office") => csv_builder.cabinet_office,
        output_key("data-labs") => csv_builder.data_labs,
        output_key("performance-analyst") => csv_builder.performance_analyst,
        output_key("third-party") => csv_builder.third_party,
      }.each { |key, data| upload_to_s3(key, data) }

      puts "Files uploaded to S3"

      PartnerNotifier.call(report)

      puts "Partners have been notified"
    end

    private_class_method :new

  private

    attr_reader :report

    def output_key(recipient)
      "#{recipient}/#{report.filename_prefix}.csv"
    end

    def upload_to_s3(key, data)
      client = Aws::S3::Resource.new.client
      client.put_object(bucket: ENV.fetch("S3_BUCKET"),
                        key: ENV.fetch("S3_PATH_PREFIX", "") + key,
                        body: data)
    end
  end
end
