FactoryBot.define do
  factory :month_entry do
    simulation { nil }
    leave_period { nil }
    year { 1 }
    month { 1 }
    prorata { "9.99" }
    gross_salary { "9.99" }
    leave_mode_a { "9.99" }
    leave_mode_b { "9.99" }
    leave_mode_c { "9.99" }
  end
end
