RSpec.describe "Delete data" do
  around do |example|
    freeze_time { example.run }
  end

  it "fetches surveys and creates files for them" do
    survey_id = AskExport.config(:survey_id)

    old_responses = ask_smart_survey_responses(
      2, { date_ended: 4.months.ago }
    )

    old_responses_requests = stub_get_responses(
      survey_id, old_responses.dup, { until_time: 3.months.ago }
    )

    partial_responses = ask_smart_survey_responses(2, { status: "partial" })

    partial_responses_requests = stub_get_responses(
      survey_id, partial_responses.dup, { completed: "0" }
    )

    delete_requests = (old_responses + partial_responses).map do |response|
      stub_delete_response(survey_id, response[:id])
    end

    ClimateControl.modify(SMART_SURVEY_API_TOKEN: "token",
                          SMART_SURVEY_API_TOKEN_SECRET: "token") do
      Rake::Task["delete_data"].invoke
    end

    all_requests = old_responses_requests + partial_responses_requests + delete_requests
    all_requests.each { |request| expect(request).to have_been_made }
  end
end
