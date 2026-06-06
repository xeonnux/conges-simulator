require 'rails_helper'

RSpec.describe Calculators::PeriodCalculator do
  describe '.call' do
    it 'splits a multi-year contract into 3 periods' do
      simulation = build(:simulation,
        start_date: Date.new(2023, 9, 11),
        end_date: Date.new(2025, 7, 25)
      )

      periods = described_class.call(simulation)

      expect(periods.length).to eq(3)

      expect(periods[0]).to have_attributes(
        start_date: Date.new(2023, 9, 11),
        end_date: Date.new(2024, 5, 31)
      )
      expect(periods[1]).to have_attributes(
        start_date: Date.new(2024, 6, 1),
        end_date: Date.new(2025, 5, 31)
      )
      expect(periods[2]).to have_attributes(
        start_date: Date.new(2025, 6, 1),
        end_date: Date.new(2025, 7, 25)
      )
    end

    it 'returns 1 period for a contract within a single reference year' do
      simulation = build(:simulation,
        start_date: Date.new(2025, 1, 15),
        end_date: Date.new(2025, 3, 20)
      )

      periods = described_class.call(simulation)

      expect(periods.length).to eq(1)
      expect(periods[0]).to have_attributes(
        start_date: Date.new(2025, 1, 15),
        end_date: Date.new(2025, 3, 20)
      )
    end

    it 'handles contract starting exactly June 1st' do
      simulation = build(:simulation,
        start_date: Date.new(2024, 6, 1),
        end_date: Date.new(2025, 5, 31)
      )

      periods = described_class.call(simulation)

      expect(periods.length).to eq(1)
      expect(periods[0]).to have_attributes(
        start_date: Date.new(2024, 6, 1),
        end_date: Date.new(2025, 5, 31)
      )
    end

    it 'handles contract ending exactly May 31st' do
      simulation = build(:simulation,
        start_date: Date.new(2023, 9, 11),
        end_date: Date.new(2025, 5, 31)
      )

      periods = described_class.call(simulation)

      expect(periods.length).to eq(2)
      expect(periods.last.end_date).to eq(Date.new(2025, 5, 31))
    end

    it 'creates 2 periods when contract crosses a single May 31st' do
      simulation = build(:simulation,
        start_date: Date.new(2024, 3, 1),
        end_date: Date.new(2024, 9, 30)
      )

      periods = described_class.call(simulation)

      expect(periods.length).to eq(2)
      expect(periods[0].end_date).to eq(Date.new(2024, 5, 31))
      expect(periods[1].start_date).to eq(Date.new(2024, 6, 1))
    end

    it 'returns LeavePeriod-like objects (not yet persisted)' do
      simulation = build(:simulation)
      periods = described_class.call(simulation)
      expect(periods.first).to respond_to(:start_date, :end_date)
    end
  end
end
