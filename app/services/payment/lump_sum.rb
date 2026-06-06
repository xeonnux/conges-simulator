module Payment
  class LumpSum
    def self.call(periods:, months:, simulation:)
      payments = Array.new(months.length, 0.0)
      last_month_idx = months.length - 1

      periods.each do |period|
        is_terminal = (period.end_date == simulation.end_date)
        closes_normally = (period.end_date.month == 5 && period.end_date.day == 31)

        if closes_normally && !is_terminal
          # Period closed on May 31 → pay in the next month (always June 1)
          payment_date = period.end_date + 1
          idx = months.index { |m| m[:year] == payment_date.year && m[:month] == payment_date.month }
          payments[idx] += period.leave_value.round(2) if idx
        else
          payments[last_month_idx] += period.leave_value.round(2)
        end
      end

      payments
    end
  end
end
