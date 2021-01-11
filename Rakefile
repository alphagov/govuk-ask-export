require "rubocop/rake_task"
require "rspec/core/rake_task"
require_relative "lib/ask_export"

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new

task default: %w[rubocop spec]

desc "Export questions from Smart Survey"
task :file_export do
  config_path = File.expand_path("config/pipelines.yml", __dir__)

  pipelines = AskExport::Pipeline.load_all(config_path)
  report_builder = AskExport::ReportBuilder.new

  pipelines.each { |pipeline| pipeline.run(report_builder) }
end
