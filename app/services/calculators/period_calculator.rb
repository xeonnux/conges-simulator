require "ostruct"

module Calculators
  class PeriodCalculator
    # Accepts a Simulation (or any object with .start_date and .end_date)
    # Returns an Array<OpenStruct> with :start_date, :end_date
    # and nil-initialized attributes for later enrichment
    def self.call(simulation)
      periods = []
      current_start = simulation.start_date

      loop do
        # Step 1: Find the next May 31 boundary
        # If we're in June or later → next boundary is May 31 of NEXT year
        # If we're in Jan–May     → next boundary is May 31 of SAME year
        boundary = if current_start.month >= 6
          Date.new(current_start.year + 1, 5, 31)
        else
          Date.new(current_start.year, 5, 31)
        end

        # Step 2: Does the contract end before this boundary?
        if boundary >= simulation.end_date
          # Yes → this is the last period, it ends at contract end
          periods << build_period(current_start, simulation.end_date)
          break
        else
          # No → full period up to May 31, then loop continues from June 1
          periods << build_period(current_start, boundary)
          current_start = boundary + 1 # June 1
        end
      end

      periods
    end

    private

    def self.build_period(start_date, end_date)
      OpenStruct.new(
        start_date: start_date,
        end_date: end_date,
        days_acquired: nil,
        months_worked: nil,
        total_salaries: nil,
        maintien_value: nil,
        ten_percent_value: nil,
        leave_value: nil
      )
    end
  end
end
