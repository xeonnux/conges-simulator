module Payment
  class MonthlyTenth
    def self.call(periods:, months:, simulation:)
      payments = Array.new(months.length, 0.0)
      last_month_idx = months.length - 1

      # Step 1: Pay 10% of gross salary every single month
      months.each_with_index do |m, idx|
        payments[idx] += m[:gross_salary] * 0.10
      end

      # Step 2: Add regularization for each period
      periods.each do |period|
        is_terminal = (period.end_date == simulation.end_date)
        closes_normally = (period.end_date.month == 5 && period.end_date.day == 31)

        # Find all months that belong to THIS period
        period_months_with_idx = months.each_with_index.select do |m, _idx|
          month_start = Date.new(m[:year], m[:month], 1)
          period_start_month = Date.new(period.start_date.year, period.start_date.month, 1)
          period_end_month = Date.new(period.end_date.year, period.end_date.month, 1)
          month_start >= period_start_month && month_start <= period_end_month
        end

        # Sum of 10% already paid on this period's months
        ten_pct_already_paid = period_months_with_idx.sum { |m, _| m[:gross_salary] * 0.10 }

        # Regularization = leave_value - what was already paid via 10%
        regularization = period.leave_value - ten_pct_already_paid

        if closes_normally && !is_terminal
          # Pay regularization in June (first month AFTER the period)
          june_date = period.end_date + 1  # June 1
          june_idx = months.index { |m| m[:year] == june_date.year && m[:month] == june_date.month }
          payments[june_idx] += regularization if june_idx
        else
          # Terminal: pay regularization on the last month
          payments[last_month_idx] += regularization
        end
      end

      payments
    end
  end
end
