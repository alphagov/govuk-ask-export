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

desc "Run the process to export questions and output them as files"
task :file_export do
  AskExport::FileExport.call
end
