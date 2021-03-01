module GoogleDriveHelper
  def stub_drive_authentication
    allow(Google::Auth::ServiceAccountCredentials).to receive(:make_creds)
                                                  .and_return("secret credentials")
  end

  def stub_google_drive_upload(filename, folder_id)
    stub_request(:post, %r{googleapis\.com/upload/drive/v3/files\?fields=id&supportsAllDrives=true})
    .with(
      body: "{\"name\":\"#{filename}\",\"parents\":[\"#{folder_id}\"]}",
      headers: {
        "X-Goog-Upload-Header-Content-Type" => "text/csv",
      },
    ).and_return(
      body: { id: 1 }.to_json,
      headers: {
        content_type: "application/json",
        # pretend the multi-request upload completed
        x_goog_upload_status: "final",
      },
    )
  end

  def stub_google_drive_list_files(folder_id, files)
    files_response = files.map do |file|
      { "kind": "drive#file" }.merge(file)
    end

    stub_request(:get, %r{googleapis\.com/drive/v3/files})
    .with(
      query: hash_including({
        "fields" => "files(id,name,createdTime)",
        "pageSize" => "1000",
        "includeItemsFromAllDrives" => "true",
        "supportsAllDrives" => "true",
        "q" => "'#{folder_id}' in parents",
      }),
    ).and_return(
      body: {
        "kind": "drive#fileList",
        "files": files_response,
      }.to_json,
      headers: {
        content_type: "application/json",
      },
    )
  end

  def stub_google_drive_delete_file(id)
    stub_request(:delete, %r{googleapis\.com/drive/v3/files/#{id}})
    .with(
      query: hash_including({
        "supportsAllDrives" => "true",
      }),
    ).and_return(
      headers: {
        content_type: "application/json",
      },
    )
  end
end
