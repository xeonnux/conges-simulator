require 'rails_helper'

RSpec.describe Payment::LumpSum do
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

  it 'returns one amount per month' do
    expect(payments.length).to eq(scenario[:months].length)
  end

  it 'pays period 1 value in June 2024' do
    idx = scenario[:months].index { |m| m[:year] == 2024 && m[:month] == 6 }
    expect(payments[idx]).to be_within(0.01).of(scenario[:periods][0].leave_value)
  end

  it 'pays period 2 value in June 2025' do
    idx = scenario[:months].index { |m| m[:year] == 2025 && m[:month] == 6 }
    expect(payments[idx]).to be_within(0.01).of(scenario[:periods][1].leave_value)
  end

  it 'pays period 3 (terminal) on the last month' do
    expect(payments.last).to be_within(0.01).of(scenario[:periods][2].leave_value)
  end

  it 'pays 0 on non-payment months' do
    payment_indices = [
      scenario[:months].index { |m| m[:year] == 2024 && m[:month] == 6 },
      scenario[:months].index { |m| m[:year] == 2025 && m[:month] == 6 },
      payments.length - 1
    ]
    payments.each_with_index do |amount, idx|
      expect(amount).to eq(0.0) unless payment_indices.include?(idx)
    end
  end

  it 'total equals sum of all leave values' do
    expect(payments.sum).to be_within(0.01).of(scenario[:periods].sum(&:leave_value))
  end

  context 'contract ending before first June' do
    let(:scenario) do
      ScenarioBuilder.build(start_date: Date.new(2025, 1, 15), end_date: Date.new(2025, 3, 20), monthly_salary: 500.0)
    end

    it 'pays everything on the last month' do
      expect(payments.last).to be_within(0.01).of(scenario[:periods].sum(&:leave_value))
    end
  end
end
