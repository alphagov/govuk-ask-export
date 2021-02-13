module SmartSurveyHelper
  def stub_get_responses(survey_id, number_of_responses, options = {})
    url = "https://api.smartsurvey.io/v1/surveys/#{survey_id}/responses"

    query = {
      since: options[:since_time]&.to_i&.to_s,
      until: options[:until_time]&.to_i&.to_s,
    }.merge(auth_parameters).compact

    max_page_size = options.fetch(:page_size, 100)
    page = 1
    requests = []

    while number_of_responses >= 0
      page_size = [max_page_size, number_of_responses].min

      responses = ask_smart_survey_responses(page_size)
      body = JSON.generate(responses)

      requests << stub_request(:get, url)
        .with(query: hash_including(query.merge({ page: page.to_s })))
        .to_return(body: body, status: 200)

      page += 1
      number_of_responses -= page_size

      break if page_size == 0
    end

    requests
  end

  def stub_delete_response(survey_id, response_id)
    url = "https://api.smartsurvey.io/v1/surveys/#{survey_id}/responses/#{response_id}"

    body = "{
      \"status\": 200,
      \"code\": \"success\",
      \"message\": \"Survey response has been deleted.\"
    }"

    stub_request(:delete, url)
      .with(query: hash_including(auth_parameters))
      .to_return(body: body, status: 200)
  end

  def auth_parameters
    {
      "api_token" => anything,
      "api_token_secret" => anything,
    }
  end

  def ask_smart_survey_responses(count, options = {})
    count.times.map do
      params = {
        id: options[:id],
        date_started: options[:start_time],
        date_ended: options[:end_time],
        status: options[:status],
      }.compact

      hash(:response, **params, pages: [
        hash(:page, questions: [
          hash(:question, :radio),
        ]),
        hash(:page, questions: [
          hash(:question, :text, id: AskExport.config(:name_field_id)),
          hash(:question, :dropdown, id: AskExport.config(:region_field_id)),
          hash(:question, :text, id: AskExport.config(:phone_field_id)),
          hash(:question, :text, id: AskExport.config(:email_field_id)),
        ]),
        hash(:page, questions: [
          hash(:question, :essay, id: AskExport.config(:question_field_id)),
        ]),
        hash(:page, questions: [
          hash(:question, :radio, id: AskExport.config(:share_video_field_id)),
        ]),
      ])
    end
  end
end
