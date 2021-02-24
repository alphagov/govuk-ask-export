RSpec.describe "Clean up export targets" do
  around do |example|
    freeze_time { example.run }
  end

  it "fetches surveys and creates files for them" do
    stub_aws_s3_client
    stub_drive_authentication

    co_files = [
      { id: 1, name: "file-1", createdTime: 3.months.ago.iso8601.to_s },
      { id: 2, name: "file-2", createdTime: 1.months.ago.iso8601.to_s },
    ]

    tp_files = [
      { id: 3, name: "file-1", createdTime: 3.months.ago.iso8601.to_s },
      { id: 4, name: "file-2", createdTime: 1.months.ago.iso8601.to_s },
    ]
    stub_google_drive_list_files("cabinet-office", co_files)
    stub_google_drive_list_files("third-party", tp_files)

    stubs = [1, 3].map do |id|
      stub_google_drive_delete_file(id)
    end

    ClimateControl.modify(FOLDER_ID_CABINET_OFFICE: "cabinet-office",
                          FOLDER_ID_THIRD_PARTY: "third-party",
                          SMART_SURVEY_API_TOKEN: "token",
                          SMART_SURVEY_API_TOKEN_SECRET: "token") do
      Rake::Task["run_cleanup"].invoke
    end

    stubs.each do |stub|
      expect(stub).to have_been_requested
    end
  end
end
