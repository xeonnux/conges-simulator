require 'rails_helper'

RSpec.describe Simulation, type: :model do
  # -- Associations --
  describe 'associations' do
    it { should have_many(:leave_periods).dependent(:destroy) }
    it { should have_many(:month_entries).dependent(:destroy) }
  end

  # -- Validations --
  describe 'validations' do
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }
    it { should validate_presence_of(:monthly_salary) }

    it { should validate_numericality_of(:monthly_salary)
           .is_greater_than_or_equal_to(200)
           .is_less_than_or_equal_to(1200) }

    describe 'end_date must be after start_date' do
      it 'is valid when end_date is after start_date' do
        sim = build(:simulation, start_date: Date.new(2024, 1, 1), end_date: Date.new(2024, 12, 31))
        expect(sim).to be_valid
      end

      it 'is invalid when end_date equals start_date' do
        sim = build(:simulation, start_date: Date.new(2024, 1, 1), end_date: Date.new(2024, 1, 1))
        expect(sim).not_to be_valid
        expect(sim.errors[:end_date]).to include(/postérieure/)
      end

      it 'is invalid when end_date is before start_date' do
        sim = build(:simulation, start_date: Date.new(2025, 1, 1), end_date: Date.new(2024, 1, 1))
        expect(sim).not_to be_valid
        expect(sim.errors[:end_date]).to include(/postérieure/)
      end
    end

    describe 'salary boundaries' do
      it 'accepts 200.00' do
        sim = build(:simulation, monthly_salary: 200.0)
        expect(sim).to be_valid
      end

      it 'accepts 1200.00' do
        sim = build(:simulation, monthly_salary: 1200.0)
        expect(sim).to be_valid
      end

      it 'rejects 199.99' do
        sim = build(:simulation, monthly_salary: 199.99)
        expect(sim).not_to be_valid
      end

      it 'rejects 1200.01' do
        sim = build(:simulation, monthly_salary: 1200.01)
        expect(sim).not_to be_valid
      end
    end
  end
end
