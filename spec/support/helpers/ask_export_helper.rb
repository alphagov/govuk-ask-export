module AskExportHelper
  def presented_survey_response(options = {})
    {
      id: options.fetch(:id, random_id),
      submission_time: "2020-05-01T09:00:00+01:00",
      region: options.fetch(:region, "Greater London"),
      question: "A question?",
      question_format: "In writing, to be read out at the press conference",
      name: "Jane Doe",
      email: "jane@example.com",
      phone: "+447123456789",
    }
  end

private

  def random_id
    rand(0..100_000)
  end
end
