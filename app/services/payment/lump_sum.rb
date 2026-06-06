module Payment
  class LumpSum
    # periods: Array<OpenStruct> (enriched with .leave_value)
    # months:  Array<Hash> ({ year:, month:, prorata:, gross_salary: })
    # simulation: anything with .start_date, .end_date
    # Returns: Array<Float> — one payment amount per month
    def self.call(periods:, months:, simulation:)
      # TODO: implement
      Array.new(months.length, 0.0)
    end
  end
end
