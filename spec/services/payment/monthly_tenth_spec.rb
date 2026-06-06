require 'rails_helper'

RSpec.describe Payment::MonthlyTenth do
  let(:scenario) do
    ScenarioBuilder.build(
      start_date: Date.new(2023, 9, 11),
      end_date: Date.new(2025, 7, 25),
      monthly_salary: 500.0
    )
  end
  let(:payments) do
    described_class.call(
      periods: scenario[:periods],
      months: scenario[:months],
      simulation: scenario[:simulation]
    )
  end

  it 'pays at least 10% of gross salary every month' do
    scenario[:months].each_with_index do |m, idx|
      base = m[:gross_salary] * 0.10
      expect(payments[idx]).to be >= (base - 0.01),
        "Month #{m[:year]}-#{m[:month]}: expected >= #{base}, got #{payments[idx]}"
    end
  end

  it 'adds regularization in June 2024 (more than just 10%)' do
    idx = scenario[:months].index { |m| m[:year] == 2024 && m[:month] == 6 }
    base_10pct = scenario[:months][idx][:gross_salary] * 0.10
    expect(payments[idx]).to be > base_10pct
  end

  it 'never produces a negative payment' do
    payments.each_with_index do |amount, idx|
      m = scenario[:months][idx]
      expect(amount).to be >= 0, "Negative at #{m[:year]}-#{m[:month]}"
    end
  end

  it 'total equals sum of all leave values' do
    expect(payments.sum).to be_within(0.01).of(scenario[:periods].sum(&:leave_value))
  end

  context 'contract ending before first June' do
    let(:scenario) do
      ScenarioBuilder.build(start_date: Date.new(2025, 1, 15), end_date: Date.new(2025, 3, 20), monthly_salary: 500.0)
    end

    it 'total equals all leave values' do
      expect(payments.sum).to be_within(0.01).of(scenario[:periods].sum(&:leave_value))
    end
  end
end
