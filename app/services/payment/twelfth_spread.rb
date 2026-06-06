module Payment
  class TwelfthSpread
    def self.call(periods:, months:, simulation:)
      payments = Array.new(months.length, 0.0)
      last_month_idx = months.length - 1

      periods.each do |period|
        is_terminal = (period.end_date == simulation.end_date)
        closes_normally = (period.end_date.month == 5 && period.end_date.day == 31)

        if closes_normally && !is_terminal
          twelfth = (period.leave_value / 12.0).round(2)
          start_of_spread = period.end_date + 1
          paid_so_far = 0.0

          12.times do |i|
            spread_date = start_of_spread >> i
            idx = months.index { |m| m[:year] == spread_date.year && m[:month] == spread_date.month }

            if idx.nil? || idx > last_month_idx
              payments[last_month_idx] += (period.leave_value - paid_so_far).round(2)
              break
            elsif i == 11 || idx == last_month_idx
              payments[idx] += (period.leave_value - paid_so_far).round(2)
              break
            else
              payments[idx] += twelfth
              paid_so_far += twelfth
            end
          end
        else
          payments[last_month_idx] += period.leave_value.round(2)
        end
      end

      payments
    end
  end
end
