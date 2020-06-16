require "rubocop/rake_task"
require "rspec/core/rake_task"
require_relative "lib/ask_export"

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new

task default: %w[rubocop spec]

desc "Export questions from Smart Survey, upload output CSV files to Google " \
  "Drive and share with recipients"
task :drive_export do
  AskExport::DriveExport.call
end

desc "Export questions from Smart Survey and output CSV files"
task :file_export do
  AskExport::FileExport.call
end

desc "Export a days questions from Smart Survey and import the analytics data into Big Query"
task :big_query_export do
  AskExport::BigQueryExport.call
end

desc "Daily export job that is expected to run on a schedule. This downloads " \
  "From Smart Survey, creates CSV files in Google Drive, and populates Big Query"
task :daily_export do
  report = AskExport::Report.new
  AskExport::DriveExport.call(report)
  AskExport::BigQueryExport.call(report)
end
