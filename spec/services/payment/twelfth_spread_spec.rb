require 'rails_helper'

RSpec.describe Payment::TwelfthSpread do
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

  it 'pays nothing before first June after period closes' do
    pre_june = scenario[:months].each_with_index.select { |m, _| Date.new(m[:year], m[:month], 1) < Date.new(2024, 6, 1) }
    pre_june.each { |_, idx| expect(payments[idx]).to eq(0.0) }
  end

  it 'pays 1/12th of period 1 starting June 2024' do
    idx = scenario[:months].index { |m| m[:year] == 2024 && m[:month] == 6 }
    expected = scenario[:periods][0].leave_value / 12.0
    expect(payments[idx]).to be_within(0.01).of(expected)
  end

  it 'pays only P2 1/12th in June 2025 (P1 spread is already complete)' do
    idx = scenario[:months].index { |m| m[:year] == 2025 && m[:month] == 6 }
    p2_twelfth = scenario[:periods][1].leave_value / 12.0
    expect(payments[idx]).to be_within(0.01).of(p2_twelfth)
  end

  it 'dumps all remaining balances on the last month' do
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

  context 'contract ending mid-1/12th stream' do
    let(:scenario) do
      ScenarioBuilder.build(start_date: Date.new(2024, 1, 1), end_date: Date.new(2024, 10, 31), monthly_salary: 500.0)
    end

    it 'total equals all leave values' do
      expect(payments.sum).to be_within(0.01).of(scenario[:periods].sum(&:leave_value))
    end
  end
end
