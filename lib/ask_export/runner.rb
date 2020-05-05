require "aws-sdk-s3"

module AskExport
  class Runner
    def self.call
      new.call
    end

    def initialize
      now = Time.zone.now
      @since_time = now.advance(days: -1).change(hour: 10)
      @until_time = now.change(hour: 10)
    end

    def call
      raise "Too early, submissions for today are still open" if until_time > Time.zone.now

      responses = SurveyResponseFetcher.call(since_time, until_time) do |progress|
        puts "downloaded #{progress} responses"
      end

      puts "#{responses.count} total responses from #{since_time} until #{until_time}"

      csv = CsvBuilder.new(responses)

      upload_to_s3("cabinet-office/#{Date.current}.csv", csv.cabinet_office)
      upload_to_s3("third-party/#{Date.current}.csv", csv.third_party)

      puts "Files uploaded to S3"

      PartnerNotifier.call(since_time, until_time, responses.count)

      puts "Partners have been notified"
    end

    private_class_method :new

  private

    attr_reader :since_time, :until_time

    def upload_to_s3(key, data)
      client = Aws::S3::Resource.new.client
      client.put_object(bucket: ENV.fetch("S3_BUCKET"),
                        key: ENV.fetch("S3_PATH_PREFIX", "") + key,
                        body: data)
    end
  end
end
