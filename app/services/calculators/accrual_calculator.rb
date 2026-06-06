module Calculators
  class AccrualCalculator
    DAYS_PER_MONTH = 2.5

    # period: OpenStruct with start_date, end_date
    # months: array of hashes with :prorata, :gross_salary, :year, :month
    # Returns: { days_acquired:, months_worked:, total_salaries: }
    def self.call(period:, months:)
      # Step 1: Filter months that belong to this period
      # A month belongs to a period if its calendar month falls between
      # the period's start and end months (inclusive)
      relevant_months = PeriodMonthFilter.months_for_period(months, period)

      # Step 2: Sum proratas to get months_worked
      months_worked = relevant_months.sum { |m| m[:prorata] }

      # Step 3: Days acquired = 2.5 per month, prorated for partial months
      days_acquired = relevant_months.sum { |m| DAYS_PER_MONTH * m[:prorata] }

      # Step 4: Total salaries (needed later for the 10% valuation method)
      total_salaries = relevant_months.sum { |m| m[:gross_salary] }

      { days_acquired: days_acquired, months_worked: months_worked, total_salaries: total_salaries }
    end
  end
end
