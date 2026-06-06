class SimulatorService
  def self.call(simulation)
    # ── Step 1: Pure calculations (no DB) ──

    periods = Calculators::PeriodCalculator.call(simulation)
    months  = Calculators::MonthCalculator.call(simulation)

    # Enrich each period with accrual + valuation
    periods.each do |period|
      period_months = PeriodMonthFilter.months_for_period(months, period)

      accrual = Calculators::AccrualCalculator.call(period: period, months: period_months)
      period.days_acquired  = accrual[:days_acquired]
      period.months_worked  = accrual[:months_worked]
      period.total_salaries = accrual[:total_salaries]

      valuation = Calculators::ValuationCalculator.best_method(
        monthly_salary: simulation.monthly_salary,
        days_acquired:  period.days_acquired,
        total_salaries: period.total_salaries
      )
      period.maintien_value    = valuation[:maintien]
      period.ten_percent_value = valuation[:ten_percent]
      period.leave_value       = valuation[:value]
    end

    # Calculate all 3 payment modes
    payment_lump_sum = Payment::LumpSum.call(periods: periods, months: months, simulation: simulation)
    payment_twelfth_spread = Payment::TwelfthSpread.call(periods: periods, months: months, simulation: simulation)
    payment_monthly_tenth = Payment::MonthlyTenth.call(periods: periods, months: months, simulation: simulation)

    # ── Step 2: Persist to DB (the only place ActiveRecord is touched) ──

    ActiveRecord::Base.transaction do
      # Clear previous results (in case of re-run)
      simulation.leave_periods.destroy_all
      simulation.month_entries.destroy_all

      # Persist periods
      ar_periods = periods.map do |p|
        simulation.leave_periods.create!(
          start_date:        p.start_date,
          end_date:          p.end_date,
          months_worked:     p.months_worked,
          days_acquired:     p.days_acquired,
          maintien_value:    p.maintien_value,
          ten_percent_value: p.ten_percent_value,
          leave_value:       p.leave_value
        )
      end

      # Persist month entries
      months.each_with_index do |m, idx|
        period_idx = PeriodMonthFilter.period_index_for_month(m, periods)
        simulation.month_entries.create!(
          leave_period: ar_periods[period_idx],
          year:         m[:year],
          month:        m[:month],
          prorata:      m[:prorata],
          gross_salary: m[:gross_salary],
          leave_mode_a: payment_lump_sum[idx],
          leave_mode_b: payment_twelfth_spread[idx],
          leave_mode_c: payment_monthly_tenth[idx]
        )
      end
    end

    simulation.reload
  end
end
