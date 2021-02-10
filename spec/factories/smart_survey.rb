require "ostruct"

class HashStrategy
  def initialize
    @strategy = FactoryBot.strategy_by_name(:create).new
  end

  delegate :association, to: :@strategy

  def result(evaluation)
    @strategy.result(evaluation).to_h
  end
end

FactoryBot.register_strategy(:hash, HashStrategy)

FactoryBot.define do
  sequence :answer do |n|
    "Answer #{n}"
  end

  factory :answer, class: OpenStruct do
    sequence(:id, 1_000_000_000)
    sequence(:choice_id, 100_000_000)
    choice_title { "&nbsp;" }
    type { "other" }

    trait :radio do
      type { "radio" }
      choice_title { generate(:answer) }
    end

    trait :dropdown do
      type { "dropdown" }
      choice_title { generate(:answer) }
    end

    trait :text do
      type { "text" }
      value { generate(:answer) }
    end
  end

  factory :question, class: OpenStruct do
    sequence(:id, 10_000_000)
    sequence(:title) { |n| "Question #{n}" }
    type { "single_choice" }
    answers { [association(:answer)] }

    trait :radio do
      sub_type { "radio" }
      answers { [association(:answer, :radio)] }
    end

    trait :dropdown do
      sub_type { "dropdown" }
      answers { [association(:answer, :dropdown)] }
    end

    trait :text do
      type { "open_ended" }
      sub_type { "single" }
      answers { [association(:answer, :text)] }
    end

    trait :essay do
      type { "open_ended" }
      sub_type { "essay" }
      answers { [association(:answer, :text)] }
    end
  end

  factory :page, class: OpenStruct do
    sequence(:id, 1_000_000)
    title { "" }
    sequence(:position)
    questions { [association(:question)] }
  end

  factory :response, class: OpenStruct do
    sequence(:id, 100_000_000)
    date_started { "2020-02-09T18:38:05Z" }
    date_ended { "2020-02-09T18:42:04Z" }
    status { "completed" }
    pages { [association(:page)] }
  end
end
