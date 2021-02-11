FactoryBot.define do
  factory :ask_response, class: AskExport::Response do
    sequence(:id, 1_000_000_000)
    status { "completed" }
    start_time { Time.zone.parse("2020-05-01 08:55:00+01Z") }
    end_time { Time.zone.parse("2020-05-01 09:00:00+01Z") }
    region { "England" }
    question { "A question?" }
    share_video { "Yes" }
    name { "Alex Doe" }
    email { "test@example.com" }
    phone { "123456789" }

    initialize_with do
      new(
        id: id,
        status: status,
        started: start_time,
        ended: end_time,
        answers: {
          12_861_884 => region,
          12_861_887 => question,
          12_861_888 => share_video,
          12_861_883 => name,
          12_861_886 => email,
          12_861_885 => phone,
        },
      )
    end
  end
end
