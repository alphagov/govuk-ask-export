module DriveHelper
  def stub_drive_authentication
    allow(Google::Auth::ServiceAccountCredentials).to receive(:make_creds)
                                                  .and_return("secret credentials")
  end

  def stub_drive_upload
    stub_request(:post, %r{googleapis\.com/upload/drive/v3})
      .and_return(body: { id: 1 }.to_json,
                  headers: { content_type: "application/json",
                             # pretend the multi-request upload completed
                             x_goog_upload_status: "final" })
  end

  def stub_drive_set_permissions
    stub_request(:post, %r{googleapis\.com/batch/drive/v3})
      .with(body: %r{ /drive/v3/files/.*/permissions})
  end
end
