require "rubocop/rake_task"
require "rspec/core/rake_task"
require_relative "lib/ask_export"

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new

task default: %w[rubocop spec]

desc "Export questions from Smart Survey and output CSV files"
task :file_export do
  AskExport::FileExport.call
end

desc "Export questions from Smart Survey and upload to Google Drive"
task :file_export_and_upload do
  files = AskExport::FileExport.call
  drive = AskExport::GoogleDrive.new

  puts "Uploading to Google Drive"
  files.each do |name, file|
    folder_id = AskExport::GoogleDrive.folder_id_from_env(name)

    puts "Uploading #{file[:path]} to Google Drive Folder ID: #{folder_id}"
    drive.upload_csv(file[:path], folder_id)
  end
end
