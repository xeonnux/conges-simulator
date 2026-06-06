require 'rails_helper'

RSpec.describe 'Golden reference test (Google Sheet)', type: :model do
  # Contract: 15 March 2020 → 31 January 2023, salary 506 €
  let(:simulation) do
    Simulation.create!(
      start_date: Date.new(2020, 3, 15),
      end_date: Date.new(2023, 1, 31),
      monthly_salary: 506.0
    )
  end

  before { SimulatorService.call(simulation) }

  describe 'periods' do
    let(:periods) { simulation.leave_periods.order(:start_date) }

    it 'produces 4 periods' do
      expect(periods.count).to eq(4)
    end

    it 'period 1: 15/03/2020 → 31/05/2020' do
      p1 = periods[0]
      expect(p1.start_date).to eq(Date.new(2020, 3, 15))
      expect(p1.end_date).to eq(Date.new(2020, 5, 31))
      expect(p1.months_worked).to be_within(0.01).of(2.55)
      expect(p1.days_acquired).to be_within(0.01).of(6.375)
      expect(p1.maintien_value).to be_within(0.01).of(146.63)
      expect(p1.ten_percent_value).to be_within(0.01).of(128.95)
      expect(p1.leave_value).to be_within(0.01).of(146.63)
    end

    it 'period 2: 01/06/2020 → 31/05/2021 (full year)' do
      p2 = periods[1]
      expect(p2.months_worked).to eq(12.0)
      expect(p2.days_acquired).to eq(30.0)
      expect(p2.leave_value).to be_within(0.01).of(690.0)
    end

    it 'period 3: 01/06/2021 → 31/05/2022 (full year)' do
      p3 = periods[2]
      expect(p3.months_worked).to eq(12.0)
      expect(p3.days_acquired).to eq(30.0)
      expect(p3.leave_value).to be_within(0.01).of(690.0)
    end

    it 'period 4: 01/06/2022 → 31/01/2023 (terminal)' do
      p4 = periods[3]
      expect(p4.months_worked).to eq(8.0)
      expect(p4.days_acquired).to eq(20.0)
      expect(p4.leave_value).to be_within(0.01).of(460.0)
    end

    it 'total leave value = 1986.63' do
      expect(periods.sum(:leave_value)).to be_within(0.01).of(1986.63)
    end
  end

  describe 'monthly entries' do
    let(:entries) { simulation.month_entries.order(:year, :month) }

    it 'produces 35 months (March 2020 → January 2023)' do
      expect(entries.count).to eq(35)
    end

    it 'March 2020 salary = 506 * 17/31 = 277.48' do
      mar = entries.find_by(year: 2020, month: 3)
      expect(mar.gross_salary).to be_within(0.01).of(277.48)
    end

    it 'total salary = 17481.48' do
      expect(entries.sum(:gross_salary)).to be_within(0.01).of(17481.48)
    end

    # --- Mode A spot checks ---
    it 'Mode A: June 2020 = 146.63 (P1 value)' do
      expect(entries.find_by(year: 2020, month: 6).leave_mode_a).to be_within(0.01).of(146.63)
    end

    it 'Mode A: June 2021 = 690.00 (P2 value)' do
      expect(entries.find_by(year: 2021, month: 6).leave_mode_a).to be_within(0.01).of(690.0)
    end

    it 'Mode A: June 2022 = 690.00 (P3 value)' do
      expect(entries.find_by(year: 2022, month: 6).leave_mode_a).to be_within(0.01).of(690.0)
    end

    it 'Mode A: January 2023 = 460.00 (P4 terminal)' do
      expect(entries.find_by(year: 2023, month: 1).leave_mode_a).to be_within(0.01).of(460.0)
    end

    # --- Mode B spot checks ---
    it 'Mode B: June 2020 = P1/12 = 12.22' do
      expect(entries.find_by(year: 2020, month: 6).leave_mode_b).to be_within(0.01).of(12.22)
    end

    it 'Mode B: June 2021 = P2/12 = 57.50' do
      expect(entries.find_by(year: 2021, month: 6).leave_mode_b).to be_within(0.01).of(57.50)
    end

    it 'Mode B: January 2023 = P3 remainder + P4 = 747.50' do
      expect(entries.find_by(year: 2023, month: 1).leave_mode_b).to be_within(0.01).of(747.50)
    end

    # --- Mode C spot checks ---
    it 'Mode C: March 2020 = 10% of 277.48 = 27.75' do
      expect(entries.find_by(year: 2020, month: 3).leave_mode_c).to be_within(0.01).of(27.75)
    end

    it 'Mode C: June 2020 = 10% + regularization = 68.28' do
      expect(entries.find_by(year: 2020, month: 6).leave_mode_c).to be_within(0.01).of(68.28)
    end

    it 'Mode C: June 2021 = 10% + regularization = 133.40' do
      expect(entries.find_by(year: 2021, month: 6).leave_mode_c).to be_within(0.01).of(133.40)
    end

    it 'Mode C: January 2023 = 10% + terminal regularization = 105.80' do
      expect(entries.find_by(year: 2023, month: 1).leave_mode_c).to be_within(0.01).of(105.80)
    end

    # --- THE INVARIANT ---
    it 'all 3 modes produce the same total: 1986.63' do
      total_a = entries.sum(:leave_mode_a)
      total_b = entries.sum(:leave_mode_b)
      total_c = entries.sum(:leave_mode_c)

      expect(total_a).to be_within(0.01).of(1986.63)
      expect(total_b).to be_within(0.01).of(1986.63)
      expect(total_c).to be_within(0.01).of(1986.63)
    end
  end
end
