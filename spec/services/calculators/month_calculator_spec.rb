require 'rails_helper'

RSpec.describe Calculators::MonthCalculator do
  describe '.call' do
    let(:simulation) do
      build(:simulation,
        start_date: Date.new(2023, 9, 11),
        end_date: Date.new(2025, 7, 25),
        monthly_salary: 500.0
      )
    end
    let(:months) { described_class.call(simulation) }

    it 'returns one entry per calendar month covered' do
      # Sep 2023 → Jul 2025 = 23 months
      expect(months.length).to eq(23)
    end

    it 'prorates the first month correctly (20/30)' do
      first = months.first
      expect(first[:year]).to eq(2023)
      expect(first[:month]).to eq(9)
      expect(first[:prorata]).to be_within(0.0001).of(20.0 / 30)
    end

    it 'prorates the last month correctly (25/31)' do
      last = months.last
      expect(last[:year]).to eq(2025)
      expect(last[:month]).to eq(7)
      expect(last[:prorata]).to be_within(0.0001).of(25.0 / 31)
    end

    it 'gives prorata 1.0 for full months' do
      oct = months.find { |m| m[:year] == 2023 && m[:month] == 10 }
      expect(oct[:prorata]).to eq(1.0)
    end

    it 'calculates gross_salary as monthly_salary * prorata' do
      first = months.first
      expected = (500.0 * 20.0 / 30)
      expect(first[:gross_salary]).to be_within(0.01).of(expected)
    end

    it 'gives full salary for full months' do
      oct = months.find { |m| m[:year] == 2023 && m[:month] == 10 }
      expect(oct[:gross_salary]).to eq(500.0)
    end
  end

  context 'contract starting and ending on first/last of month' do
    let(:simulation) do
      build(:simulation,
        start_date: Date.new(2024, 1, 1),
        end_date: Date.new(2024, 12, 31),
        monthly_salary: 500.0
      )
    end

    it 'gives prorata 1.0 for all months' do
      months = described_class.call(simulation)
      expect(months).to all(include(prorata: 1.0))
    end
  end

  context 'february in a leap year' do
    let(:simulation) do
      build(:simulation,
        start_date: Date.new(2024, 2, 10),
        end_date: Date.new(2024, 2, 28),
        monthly_salary: 600.0
      )
    end

    it 'uses 29 days for February 2024' do
      months = described_class.call(simulation)
      # Feb 10 → Feb 28 = 19 days covered out of 29
      expect(months.first[:prorata]).to be_within(0.0001).of(19.0 / 29)
    end
  end
end
