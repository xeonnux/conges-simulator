FactoryBot.define do
  factory :simulation do
    start_date { Date.new(2023, 9, 11) }
    end_date { Date.new(2025, 7, 25) }
    monthly_salary { 500.0 }
  end
end
