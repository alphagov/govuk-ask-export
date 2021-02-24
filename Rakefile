lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "rubocop/rake_task"
require "rspec/core/rake_task"
require "ask_export"

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new

task default: %w[rubocop spec]

desc "Export questions from Smart Survey"
task :run_exports do
  config_path = File.expand_path("config/pipelines.yml", __dir__)

  pipelines = AskExport::Pipeline.load_all(config_path)
  report_builder = AskExport::ReportBuilder.new

  pipelines.each { |pipeline| pipeline.run(report_builder) }
end

desc "Delete old user data from Smart Survey"
task :delete_data do
  survey_id = AskExport.config(:survey_id)
  client = SmartSurvey::Client.new

  # Delete responses over 3 months old as per privacy agreement
  p "Deleting responses over 3 months old"
  old_responses = client.list_responses(survey_id: survey_id, until_time: 3.months.ago)

  old_responses.each.with_index(1) do |response, index|
    client.delete_response(survey_id: survey_id, response_id: response.id)
    p "Deleted #{index} responses" if (index % 50).zero?
  end

  # Delete partial filled responses as they cannot be used
  p "Deleting partially filled responses"
  partial_responses = client.list_responses(survey_id: survey_id, completed: 0)

  partial_responses.each.with_index(1) do |response, index|
    client.delete_response(survey_id: survey_id, response_id: response.id)
    p "Deleted #{index} responses" if (index % 50).zero?
  end
end

desc "Delete data for pipeline targets"
task :run_cleanup do
  config_path = File.expand_path("config/pipelines.yml", __dir__)
  pipelines = AskExport::Pipeline.load_all(config_path)

  pipelines.each(&:cleanup)
end
