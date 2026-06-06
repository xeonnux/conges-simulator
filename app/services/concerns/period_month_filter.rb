module PeriodMonthFilter
  def self.months_for_period(months, period)
    months.select do |m|
      month_start = Date.new(m[:year], m[:month], 1)
      period_start_month = Date.new(period.start_date.year, period.start_date.month, 1)
      period_end_month = Date.new(period.end_date.year, period.end_date.month, 1)
      month_start >= period_start_month && month_start <= period_end_month
    end
  end

  def self.period_index_for_month(month, periods)
    periods.index do |period|
      month_start = Date.new(month[:year], month[:month], 1)
      period_start_month = Date.new(period.start_date.year, period.start_date.month, 1)
      period_end_month = Date.new(period.end_date.year, period.end_date.month, 1)
      month_start >= period_start_month && month_start <= period_end_month
    end
  end
end
