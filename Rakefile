require "rubocop/rake_task"
require "rspec/core/rake_task"
require_relative "lib/ask_export"

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new

task default: %w[rubocop spec]

desc "Run the process to export questions, upload them to S3 and notify stakeholders"
task :s3_export do
  AskExport::S3Export.call
end

desc "Split a Smart Survey CSV into files for each partner, available as a fallback if export fails"
task :split_csv_export do
  raise "usage: CSV_FILE=/path/to/file.csv bundle exec rake split_csv_export" unless ENV["CSV_FILE"]

  # It seems unusual that someone would split a draft CSV and this doesn't
  # carry the same risks as doing a live export
  ENV["SMART_SURVEY_LIVE"] ||= "true"
  AskExport::CsvSplitter.call(ENV["CSV_FILE"])
end
