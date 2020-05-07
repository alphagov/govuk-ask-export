module AskExportHelper
  def stub_smart_survey_api(options = {})
    environment = options.fetch(:environment, :draft)
    config = AskExport::CONFIG[environment]
    url = "https://api.smartsurvey.io/v1/surveys/#{config[:survey_id]}/responses"
    query = {
      since: options[:since_time]&.to_i&.to_s,
      until: options[:until_time]&.to_i&.to_s,
      page: options[:page]&.to_s,
    }.compact
    body = options.fetch(:body, smart_survey_response(50))

    stub_request(:get, url)
      .with(query: hash_including(query))
      .to_return(body: JSON.generate(body), status: options.fetch(:status, 200))
  end

  def smart_survey_response(items)
    items.times.map { smart_survey_row }
  end

  def smart_survey_row(options = {})
    environment = options.fetch(:environment, :draft)
    config = AskExport::CONFIG[environment]
    {
      id: options.fetch(:id, random_id),
      survey_id: config[:survey_id],
      date_ended: options.fetch(:submission_time, Time.zone.now.utc.iso8601),
      status: options.fetch(:status, "completed"),
      pages: [
        {
          id: random_id,
          questions: [
            {
              id: random_id,
              title: "Are you 18 or over?",
              answers: [{ choice_title: "Yes" }],
            },
          ],
        },
        {
          id: random_id,
          questions: [
            {
              id: config[:question_field_id],
              title: "What is your question?",
              answers: [{ value: options.fetch(:question, "A question?") }],
            },
            {
              id: config[:name_field_id],
              title: "What is your name?",
              answers: [{ value: options.fetch(:name, "John Smith") }],
            },
            {
              id: config[:region_field_id],
              title: "Where do you live?",
              answers: [{ choice_title: options.fetch(:region, "Yorkshire") }],
            },
            {
              id: config[:email_field_id],
              title: "What is your email address?",
              answers: [{ value: options.fetch(:email, "me@example.com") }],
            },
            {
              id: config[:phone_field_id],
              title: "What is your phone number?",
              answers: [{ value: options.fetch(:phone, "me@example.com") }],
            },
            {
              id: config[:question_format_field_id],
              title: "How would you like to ask your question?",
              answers: [{ choice_title: options.fetch(:question_format, "By video") }],
            },
          ],
        },
      ],
    }
  end

  def presented_survey_response(options = {})
    {
      id: options.fetch(:id, random_id),
      submission_time: "01/05/2020 09:00:00",
      region: options.fetch(:region, "Greater London"),
      question: "A question?",
      question_format: "In writing, to be read out at the press conference",
      name: "Jane Doe",
      email: "jane@example.com",
      phone: "+447123456789",
    }
  end

  def stubbed_daily_report(responses: [presented_survey_response])
    daily_report = AskExport::DailyReport.new
    allow(daily_report).to receive(:responses)
                       .and_return(responses)
    daily_report
  end

private

  def random_id
    rand(0..100_000)
  end
end
