# spec/support/scenario_builder.rb
#
# Builds a complete simulation scenario WITHOUT touching the database.
# Uses Simulation.new (not .create!) so all calculator specs stay DB-free.
# Reuses PeriodMonthFilter from app/services/concerns/ for consistency.
#
module ScenarioBuilder
  def self.build(start_date:, end_date:, monthly_salary:)
    # Plain ActiveRecord object, never persisted — should works because calculators
    # only call .start_date, .end_date, .monthly_salary on it.
    simulation = Simulation.new(
      start_date: start_date,
      end_date: end_date,
      monthly_salary: monthly_salary
    )

    periods = Calculators::PeriodCalculator.call(simulation)
    months  = Calculators::MonthCalculator.call(simulation)

    periods.each do |period|
      period_months = PeriodMonthFilter.months_for_period(months, period)

      accrual = Calculators::AccrualCalculator.call(period: period, months: period_months)
      period.days_acquired  = accrual[:days_acquired]
      period.months_worked  = accrual[:months_worked]
      period.total_salaries = accrual[:total_salaries]

      valuation = Calculators::ValuationCalculator.best_method(
        monthly_salary: monthly_salary,
        days_acquired:  period.days_acquired,
        total_salaries: period.total_salaries
      )
      period.maintien_value    = valuation[:maintien]
      period.ten_percent_value = valuation[:ten_percent]
      period.leave_value       = valuation[:value]
    end

    { simulation: simulation, periods: periods, months: months }
  end
end
