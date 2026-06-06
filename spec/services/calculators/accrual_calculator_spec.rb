require 'rails_helper'

RSpec.describe Calculators::AccrualCalculator do
  describe '.call' do
    it 'gives 2.5 days for one full month' do
      months = [ { year: 2024, month: 1, prorata: 1.0, gross_salary: 500.0 } ]
      period = OpenStruct.new(start_date: Date.new(2024, 1, 1), end_date: Date.new(2024, 1, 31))

      result = described_class.call(period: period, months: months)

      expect(result[:days_acquired]).to eq(2.5)
      expect(result[:months_worked]).to eq(1.0)
    end

    it 'gives 30 days for 12 full months' do
      months = (6..12).map { |m| { year: 2023, month: m, prorata: 1.0, gross_salary: 500.0 } } +
               (1..5).map  { |m| { year: 2024, month: m, prorata: 1.0, gross_salary: 500.0 } }
      period = OpenStruct.new(start_date: Date.new(2023, 6, 1), end_date: Date.new(2024, 5, 31))

      result = described_class.call(period: period, months: months)

      expect(result[:days_acquired]).to eq(30.0)
      expect(result[:months_worked]).to eq(12.0)
    end

    it 'prorates days for a partial month' do
      prorata = 20.0 / 30
      months = [ { year: 2023, month: 9, prorata: prorata, gross_salary: 500.0 * prorata } ]
      period = OpenStruct.new(start_date: Date.new(2023, 9, 11), end_date: Date.new(2023, 9, 30))

      result = described_class.call(period: period, months: months)

      expect(result[:days_acquired]).to be_within(0.01).of(2.5 * prorata)
      expect(result[:months_worked]).to be_within(0.01).of(prorata)
    end

    it 'sums across multiple months' do
      prorata_sept = 20.0 / 30
      months = [
        { year: 2023, month: 9,  prorata: prorata_sept, gross_salary: 500.0 * prorata_sept },
        { year: 2023, month: 10, prorata: 1.0, gross_salary: 500.0 },
        { year: 2023, month: 11, prorata: 1.0, gross_salary: 500.0 }
      ]
      period = OpenStruct.new(start_date: Date.new(2023, 9, 11), end_date: Date.new(2023, 11, 30))

      result = described_class.call(period: period, months: months)

      expected_days = 2.5 * prorata_sept + 2.5 + 2.5
      expect(result[:days_acquired]).to be_within(0.01).of(expected_days)
    end
  end
end
