require_relative "fetch_survey_responses"
require_relative "csv_builder"
require "time"
require "tzinfo"

class Export
  def self.call
    new.call
  end

  def call
    raise "submissions are not complete until 12" if timezone.to_local(Time.now).hour < 12

    responses = FetchSurveyResponses.call(start_time, until_time) do |progress|
      puts "downloaded #{progress} responses"
    end

    puts "#{responses.count} total responses from #{start_time} until #{until_time}"

    csv = CsvBuilder.new(responses)

    upload_to_s3("cabinet-office/#{today.to_s}.csv", csv.cabinet_office)
    upload_to_s3("third-party/#{today.to_s}.csv", csv.cabinet_office)

    puts "Files uploaded to S3"

    NotifyPartners.call(start_time, until_time, responses.count)

    puts "Partners have been notified"
  end

private

  def start_time
    @start_time ||= begin
                      yesterday = today - 1
                      timezone.local_time(yesterday.year,
                                          yesterday.month,
                                          yesterday.day,
                                          12)
                    end
  end

  def until_time
    @until_time ||= begin
                      timezone.local_time(today.year,
                                          today.month,
                                          today.day,
                                          12)
                    end
  end

  def today
    @today ||= timezone.to_local(Time.now).to_date
  end

  def timezone
    @timezone ||= TZInfo::Timezone.get("Europe/London")
  end

  def upload_to_s3(key, data)
    s3 = Aws::S3::Resource.new(region:'eu-west-1')
    obj = s3.bucket('bucket-name').object(key)
    obj.put(body: data)
  end
end
