module Payment
  class LumpSum
    # periods: Array<OpenStruct> (enriched with .leave_value)
    # months:  Array<Hash> ({ year:, month:, prorata:, gross_salary: })
    # simulation: anything with .start_date, .end_date
    # Returns: Array<Float> — one payment amount per month
    def self.call(periods:, months:, simulation:)
      payments = Array.new(months.length, 0.0)
      last_month_idx = months.length - 1

      periods.each do |period|
        # Is this the last period (ends at contract end)?
        is_terminal = (period.end_date == simulation.end_date)

        # Does this period close on May 31? (i.e. a full reference year boundary)
        closes_normally = (period.end_date.month == 5 && period.end_date.day == 31)

        if closes_normally && !is_terminal
          # Normal close: pay in the June immediately after
          june_date = period.end_date + 1  # June 1
          june_idx = months.index { |m| m[:year] == june_date.year && m[:month] == june_date.month }
          payments[june_idx] += period.leave_value if june_idx
        else
          # Terminal period OR period ending before May 31:
          # Pay everything on the last month of the contract
          payments[last_month_idx] += period.leave_value
        end
      end

      payments
    end
  end
end
