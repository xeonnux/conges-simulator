require 'rails_helper'

RSpec.describe Calculators::ValuationCalculator do
  describe '.maintien_de_salaire' do
    it 'calculates salary / 22 * days_acquired' do
      result = described_class.maintien_de_salaire(monthly_salary: 500.0, days_acquired: 30.0)
      expect(result).to be_within(0.01).of(500.0 / 22.0 * 30.0)
    end

    it 'handles partial days' do
      result = described_class.maintien_de_salaire(monthly_salary: 500.0, days_acquired: 15.5)
      expect(result).to be_within(0.01).of(500.0 / 22.0 * 15.5)
    end

    it 'returns 0 when no days acquired' do
      result = described_class.maintien_de_salaire(monthly_salary: 500.0, days_acquired: 0)
      expect(result).to eq(0.0)
    end
  end

  describe '.ten_percent' do
    it 'calculates 10% of total salaries' do
      result = described_class.ten_percent(total_salaries: 6000.0)
      expect(result).to be_within(0.01).of(600.0)
    end

    it 'handles partial periods' do
      result = described_class.ten_percent(total_salaries: 4333.33)
      expect(result).to be_within(0.01).of(433.33)
    end

    it 'returns 0 when no salaries' do
      result = described_class.ten_percent(total_salaries: 0)
      expect(result).to eq(0.0)
    end
  end

  describe '.best_method' do
    it 'returns maintien when higher' do
      result = described_class.best_method(
        monthly_salary: 500.0, days_acquired: 30.0, total_salaries: 6000.0
      )
      # maintien = 500/22*30 ≈ 681.82 > 10% = 600
      expect(result[:value]).to be_within(0.01).of(500.0 / 22.0 * 30.0)
      expect(result[:winning_method]).to eq(:maintien_de_salaire)
    end

    it 'returns ten_percent when higher' do
      result = described_class.best_method(
        monthly_salary: 500.0, days_acquired: 2.0, total_salaries: 6000.0
      )
      # maintien = 500/22*2 ≈ 45.45 < 10% = 600
      expect(result[:value]).to be_within(0.01).of(600.0)
      expect(result[:winning_method]).to eq(:ten_percent)
    end

    it 'handles equal values' do
      result = described_class.best_method(
        monthly_salary: 440.0, days_acquired: 30.0, total_salaries: 6000.0
      )
      # maintien = 440/22*30 = 600, 10% = 600
      expect(result[:value]).to be_within(0.01).of(600.0)
    end
  end
end
