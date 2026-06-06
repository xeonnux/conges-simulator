module Calculators
  class PeriodCalculator
    # Accepts a Simulation (or anything with start_date, end_date)
    # Returns an array of OpenStruct/hashes with :start_date, :end_date
    def self.call(simulation)
      # TODO: implement
      # Algorithm:
      #   current_start = simulation.start_date
      #   Find next May 31 boundary
      #   Loop until boundary >= simulation.end_date
      #   Return array of period structs
      []
    end
  end
end
