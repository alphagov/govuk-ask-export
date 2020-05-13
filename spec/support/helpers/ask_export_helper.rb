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

    row = {
      id: options.fetch(:id, random_id),
      survey_id: config[:survey_id],
      date_started: options.fetch(:start_time, Time.zone.now).utc.iso8601,
      date_ended: options.fetch(:submission_time, Time.zone.now).utc.iso8601,
      status: options.fetch(:status, "completed"),
      user_agent: options.fetch(:user_agent, "Mozilla/4.5 (compatible; HTTrack 3.0x; Windows 98)"),
      pages: [smart_survey_age_check_page(options),
              smart_survey_answers_page(options)].compact,
    }

    if options[:client_id]
      row[:variables] = [{ id: random_id,
                           name: "_ga",
                           label: "clientID",
                           value: options[:client_id] }]
    end

    row
  end

  def presented_survey_response(options = {})
    status = options.fetch(:status, "completed")
    completed = status == "completed"
    {
      id: options.fetch(:id, random_id),
      client_id: options[:client_id],
      user_agent: "NCSA Mosaic/3.0 (Windows 95)",
      status: status,
      start_time: "01/05/2020 08:55:00",
      submission_time: "01/05/2020 09:00:00",
      region: completed ? options.fetch(:region, "Greater London") : nil,
      question: completed ? "A question?" : nil,
      question_format: completed ? "In writing, to be read out at the press conference" : nil,
      name: completed ? "Jane Doe" : nil,
      email: completed ? "jane@example.com" : nil,
      phone: completed ? "+447123456789" : nil,
    }
  end

  def stubbed_report(responses: [presented_survey_response])
    report = AskExport::Report.new
    allow(report).to receive(:responses).and_return(responses)
    report
  end

private

  def smart_survey_age_check_page(options)
    {
      id: random_id,
      questions: [
        {
          id: random_id,
          title: "Are you 18 or over?",
          answers: [
            {
              choice_title: (options[:status] == "disqualified" ? "No" : "Yes"),
            },
          ],
        },
      ],
    }
  end

  def smart_survey_answers_page(options)
    return if %w[partial disqualified].include?(options[:status])

    environment = options.fetch(:environment, :draft)
    config = AskExport::CONFIG[environment]

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
          answers: [{ value: options.fetch(:phone, "0789123456") }],
        },
        {
          id: config[:question_format_field_id],
          title: "How would you like to ask your question?",
          answers: [{ choice_title: options.fetch(:question_format, "By video") }],
        },
      ],
    }
  end

  def random_id
    rand(0..100_000)
  end
end
