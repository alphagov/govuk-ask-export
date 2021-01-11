module SmartSurveyHelper
  def stub_smart_survey_api(options = {})
    environment = options.fetch(:environment, :draft)
    config = AskExport::CONFIG[environment]
    url = "https://api.smartsurvey.io/v1/surveys/#{config[:survey_id]}/responses"
    query = {
      since: options[:since_time]&.to_i&.to_s,
      until: options[:until_time]&.to_i&.to_s,
      page: options[:page]&.to_s,
    }.compact

    responses = smart_survey_response(50, environment: environment)
    body = options.fetch(:body, responses)

    stub_request(:get, url)
      .with(query: hash_including(query))
      .to_return(body: JSON.generate(body), status: options.fetch(:status, 200))
  end

  def smart_survey_response(items, options = {})
    items.times.map { smart_survey_row(options) }
  end

  def smart_survey_row(options = {})
    environment = options.fetch(:environment, :draft)
    config = AskExport::CONFIG[environment]

    row = {
      id: options.fetch(:id, random_id),
      survey_id: config[:survey_id],
      date_started: options.fetch(:start_time, Time.zone.now).utc.iso8601,
      date_ended: options.fetch(:end_time, Time.zone.now).utc.iso8601,
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

  def serialised_survey_response(options = {})
    status = options.fetch(:status, "completed")
    completed = status == "completed"
    {
      id: options.fetch(:id, random_id),
      client_id: options[:client_id],
      user_agent: "NCSA Mosaic/3.0 (Windows 95)",
      status: status,
      start_time: Time.zone.parse("2020-05-01 08:55:00"),
      end_time: Time.zone.parse("2020-05-01 09:00:00"),
      region: completed ? options.fetch(:region, "Greater London") : nil,
      question: completed ? "A question?" : nil,
      share_video: completed ? "Yes" : nil,
      name: completed ? "Jane Doe" : nil,
      email: completed ? "jane@example.com" : nil,
      phone: completed ? "+447123456789" : nil,
    }
  end

  def report_response(options = {}, secret_key = "")
    response = serialised_survey_response(options)

    status = options.fetch(:status, "completed")
    completed = status == "completed"

    response.merge({
      question: options[:question],
      start_time: "01/05/2020 08:55:00",
      submission_time: "01/05/2020 09:00:00",
      hashed_email: completed ? Digest::SHA256.hexdigest("jane@example.com" + secret_key) : nil,
      hashed_phone: completed ? Digest::SHA256.hexdigest("+447123456789" + secret_key) : nil,
    }.compact)
  end

  def stubbed_report(responses: [serialised_survey_response])
    report = AskExport::Report.new
    allow(report).to receive(:responses).and_return(responses)
    report
  end

private

  def smart_survey_age_check_page(options)
    choice = options[:status] == "disqualified" ? "No" : "Yes"

    {
      id: random_id,
      questions: [
        smart_survey_answer(random_id,
                            "Are you 18 or over?",
                            choice,
                            :choice_title),
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
        smart_survey_answer(config[:question_field_id],
                            "What is your question?",
                            options.fetch(:question, "A question?"),
                            :value),
        smart_survey_answer(config[:name_field_id],
                            "What is your name?",
                            options.fetch(:name, "John Smith"),
                            :value),
        smart_survey_answer(config[:region_field_id],
                            "Where do you live?",
                            options.fetch(:region, "Yorkshire"),
                            :choice_title),
        smart_survey_answer(config[:email_field_id],
                            "What is your email address?",
                            options.fetch(:email, "me@example.com"),
                            :value),
        smart_survey_answer(config[:phone_field_id],
                            "What is your phone number?",
                            options.fetch(:phone, "0789123456"),
                            :value),
        smart_survey_answer(config[:share_video_field_id],
                            "Are you happy to record a video asking your question?",
                            options.fetch(:share_video, "Yes"),
                            :choice_title),
      ].compact,
    }
  end

  def smart_survey_answer(id, title, answer, type)
    return unless answer

    { id: id, title: title, answers: [{ type => answer }] }
  end

  def random_id
    rand(0..100_000)
  end
end
