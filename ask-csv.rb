#!/usr/bin/env ruby

# Usage `ruby ask-csv.rb <smart-survey-export>`
#
# This converts an exported Smart Survey into 3 files: one for GOV.UK analytics
# to track user journeys, one to be sent to Cabinet Office and one to be sent
# to the third party who picks the questions
#
# The survey should be exported by following these steps
#
# - Go to Smart Survey and select the appropriate survey
# - Click on Results, then go to Export
# - Name your export for the day you are exporting, select the Raw Response Data
#   option and choose the CSV format
# - Click on the customise section
# - In the options tab ensure that "Include respondant details" is turned on
# - In the appearance tab change the "Column heading style" to be "Display
#   Question ID's - E.g. Q1001, Q1002..."
# - In the filters tab:
#   - Turn on "Select custom filter" and choose "Completed Over 18 Responses"
#   - Go to the "Date range" field and select "Custom range"
#     then adjust the "From" time to be 12pm on the previous day and
#     the "To" time to be 12pm on the current day
# - Click "Export" and wait for the report to be generated, then click the
#   download link to save the file

require "csv"

# These will need to be updated if we add or remove questions
NAME_FIELD = "Q11289065"
QUESTION_FIELD = "Q11288904"
EMAIL_FIELD = "Q11289069"
REGION_FIELD = "Q11312915"
PHONE_FIELD = "Q11312922"
QUESTION_FORMAT_FIELD = "Q11324295"

smart_survey_export = ARGV.pop

govuk_analaytics_csv = []
cabinet_office_csv = []
third_party_csv = []

# Note exported smart surveys seem to have a BOM character
CSV.foreach(smart_survey_export, headers: true, encoding: "bom|utf-8") do |csv|
  next if csv["UserID"].empty?

  missing_fields = [
    NAME_FIELD,
    QUESTION_FIELD,
    EMAIL_FIELD,
    REGION_FIELD,
    PHONE_FIELD,
    QUESTION_FORMAT_FIELD,
  ].any? { |f| csv[f].nil? }

  raise "Missing expected fields" if missing_fields

  govuk_analaytics_csv << { start_time: csv["Started"],
                            end_time: csv["Ended"],
                            client_id: csv["clientID"],
                            page_path: csv["Page Path"] }

  cabinet_office_csv << { id: csv["UserID"],
                          submission_time: csv["Ended"],
                          region: csv[REGION_FIELD],
                          name: csv[NAME_FIELD],
                          email: csv[EMAIL_FIELD],
                          phone: csv[PHONE_FIELD],
                          question_format: csv[QUESTION_FORMAT_FIELD] }

  third_party_csv << { id: csv["UserID"],
                       submission_time: csv["Ended"],
                       region: csv[REGION_FIELD],
                       question: csv[QUESTION_FIELD],
                       question_format: csv[QUESTION_FORMAT_FIELD] }
end

def write_csv(path, data)
  raise "we don't seem to have any data, is the CSV empty?" if data.empty?

  CSV.open(path, "wb") do |csv|
    csv << data.first.keys
    data.each { |row| csv << row.values }
  end
end

date = Date.today.to_s

write_csv("govuk-analytics-#{date}.csv", govuk_analaytics_csv)
write_csv("cabinet-office-#{date}.csv", cabinet_office_csv)
write_csv("third-party-#{date}.csv", third_party_csv)