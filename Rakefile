require "rubocop/rake_task"
require "rspec/core/rake_task"
require_relative "lib/ask_export"

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new

task default: %w[rubocop spec]

desc "Export questions from Smart Survey, upload output CSV files to Google " \
  "Drive and share with recipients"
task :drive_export do
  report = Report.new
  AskExport::DriveExport.call(report)
  AskExport::BigQueryExport.call(report)
end

desc "Export questions from Smart Survey and output CSV files"
task :file_export do
  AskExport::FileExport.call
end

desc "Export questions from Smart Survey and import the results into Big Query"
task :big_query_export do
  AskExport::BigQueryExport.call
end
