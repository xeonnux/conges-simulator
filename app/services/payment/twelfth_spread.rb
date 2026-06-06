module Payment
  class TwelfthSpread
    def self.call(periods:, months:, simulation:)
      payments = Array.new(months.length, 0.0)
      last_month_idx = months.length - 1

      periods.each do |period|
        is_terminal = (period.end_date == simulation.end_date)
        closes_normally = (period.end_date.month == 5 && period.end_date.day == 31)

        if closes_normally && !is_terminal
          # Period closed normally on May 31 → spread 1/12th over next 12 months
          twelfth = period.leave_value / 12.0
          start_of_spread = period.end_date + 1  # June 1

          12.times do |i|
            spread_date = start_of_spread >> i  # >> advances by i months
            idx = months.index { |m| m[:year] == spread_date.year && m[:month] == spread_date.month }

            if idx && idx <= last_month_idx
              payments[idx] += twelfth
            else
              # Month is beyond contract end → dump remaining on last month
              remaining = twelfth * (12 - i)
              payments[last_month_idx] += remaining
              break
            end
          end
        else
          # Terminal period OR period not yet closed:
          # Pay the full value on the last month
          payments[last_month_idx] += period.leave_value
        end
      end

      payments
    end
  end
end
