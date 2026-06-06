module Calculators
  class MonthCalculator
    # Returns array of hashes: { year:, month:, prorata:, gross_salary: }
    def self.call(simulation)
      months = []
      current = Date.new(simulation.start_date.year, simulation.start_date.month, 1)
      last_month = Date.new(simulation.end_date.year, simulation.end_date.month, 1)

      while current <= last_month
        y = current.year
        m = current.month

        days_in_month = Date.new(y, m, -1).day
        first_day = [ simulation.start_date, Date.new(y, m, 1) ].max
        last_day  = [ simulation.end_date, Date.new(y, m, -1) ].min
        days_covered = (last_day - first_day).to_i + 1
        prorata = days_covered.to_f / days_in_month
        gross_salary = simulation.monthly_salary * prorata

        months << { year: y, month: m, prorata: prorata, gross_salary: gross_salary }

        current = current.next_month
      end

      months
    end
  end
end
