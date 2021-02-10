require "smart_survey/response"

module AskExport
  class Response < ::SmartSurvey::Response
    attr_accessor :region, :question, :share_video, :name, :email, :phone
    alias_method :end_time, :ended
    alias_method :start_time, :started

    def initialize(**kwargs)
      super(kwargs)
      @region = fetch_answer(:region_field_id)
      @question = fetch_answer(:question_field_id)
      @share_video = fetch_answer(:share_video_field_id)
      @name = fetch_answer(:name_field_id)
      @email = fetch_answer(:email_field_id)
      @phone = fetch_answer(:phone_field_id)
    end

    def status
      # We've had situations where an incomplete survey response is returned
      # from Smart Survey with a "completed" status this seems to because
      # Smart Survey enforces required fields only on the client side
      required_attr = [@region, @question, @share_video, @name, @email, @phone]

      if @status == "completed" && required_attr.any?(&:blank?)
        "partial"
      else
        @status
      end
    end

  private

    def fetch_answer(field_id)
      @answers[AskExport.config(field_id)]
    end
  end
end
