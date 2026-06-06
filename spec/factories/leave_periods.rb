FactoryBot.define do
  factory :leave_period do
    simulation { nil }
    start_date { "2026-06-06" }
    end_date { "2026-06-06" }
    months_worked { "9.99" }
    days_acquired { "9.99" }
    maintien_value { "9.99" }
    ten_percent_value { "9.99" }
    leave_value { "9.99" }
  end
end
