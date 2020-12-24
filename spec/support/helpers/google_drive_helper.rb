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
end
