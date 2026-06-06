module Calculators
  class MonthCalculator
    # Returns array of hashes: { year:, month:, prorata:, gross_salary: }
    def self.call(simulation)
      # TODO: implement
      # Iterate month by month from start_date to end_date
      # For each month compute:
      #   days_in_month = Date.new(y, m, -1).day
      #   first_day = [simulation.start_date, Date.new(y, m, 1)].max
      #   last_day  = [simulation.end_date, Date.new(y, m, -1)].min
      #   days_covered = (last_day - first_day).to_i + 1
      #   prorata = days_covered.to_f / days_in_month
      #   gross_salary = simulation.monthly_salary * prorata
      []
    end
  end
end
