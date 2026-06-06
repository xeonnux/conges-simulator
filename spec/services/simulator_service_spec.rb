require 'rails_helper'

RSpec.describe SimulatorService do
  test_cases = [
    { start: Date.new(2023, 9, 11), end_date: Date.new(2025, 7, 25), salary: 500.0,  label: 'multi-year' },
    { start: Date.new(2025, 1, 15), end_date: Date.new(2025, 3, 20), salary: 800.0,  label: 'short contract' },
    { start: Date.new(2024, 6, 1),  end_date: Date.new(2025, 5, 31), salary: 400.0,  label: 'exact 1 period' },
    { start: Date.new(2024, 1, 1),  end_date: Date.new(2024, 10, 31), salary: 600.0, label: 'mid-year end' },
    { start: Date.new(2024, 3, 15), end_date: Date.new(2024, 4, 10),  salary: 200.0, label: 'very short' },
    { start: Date.new(2023, 1, 1),  end_date: Date.new(2026, 12, 31), salary: 1200.0, label: 'long max salary' }
  ]

  test_cases.each do |tc|
    context "#{tc[:label]}: #{tc[:start]} → #{tc[:end_date]}, #{tc[:salary]}€" do
      let(:simulation) do
        Simulation.create!(start_date: tc[:start], end_date: tc[:end_date], monthly_salary: tc[:salary])
      end
      let(:result) { described_class.call(simulation) }

      it 'persists leave_periods' do
        result
        expect(simulation.leave_periods.count).to be >= 1
      end

      it 'persists month_entries' do
        result
        expect(simulation.month_entries.count).to be >= 1
      end

      it 'all 3 payment modes produce the same total (THE INVARIANT)' do
        result
        entries = simulation.month_entries

        total_a = entries.sum(:leave_mode_a)
        total_b = entries.sum(:leave_mode_b)
        total_c = entries.sum(:leave_mode_c)
        total_leave = simulation.leave_periods.sum(:leave_value)

        expect(total_a).to be_within(0.01).of(total_leave),
          "Mode A: #{total_a} != #{total_leave}"
        expect(total_b).to be_within(0.01).of(total_leave),
          "Mode B: #{total_b} != #{total_leave}"
        expect(total_c).to be_within(0.01).of(total_leave),
          "Mode C: #{total_c} != #{total_leave}"
      end

      it 'every month has a non-negative salary' do
        result
        simulation.month_entries.each do |entry|
          expect(entry.gross_salary).to be >= 0
        end
      end
    end
  end
end
