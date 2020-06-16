module NotifyHelper
  def stub_post_notify
    stub_request(:post, /api\.notifications\.service\.gov\.uk/)
      .and_return(body: "{}")
  end
end
