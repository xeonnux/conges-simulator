module Calculators
  class ValuationCalculator
    DAYS_PER_MONTH = 22.0 # This is a constant that is global and never changes.

    def self.maintien_de_salaire(monthly_salary:, days_acquired:)
      (monthly_salary / DAYS_PER_MONTH) * days_acquired
    end

    def self.ten_percent(total_salaries:)
      total_salaries * 0.10
    end

    def self.best_method(monthly_salary:, days_acquired:, total_salaries:)
      maintien = maintien_de_salaire(monthly_salary: monthly_salary, days_acquired: days_acquired)
      ten_pct = ten_percent(total_salaries: total_salaries)

      if maintien >= ten_pct
        { value: maintien, winning_method: :maintien_de_salaire, maintien: maintien, ten_percent: ten_pct }
      else
        { value: ten_pct, winning_method: :ten_percent, maintien: maintien, ten_percent: ten_pct }
      end
    end
  end
end
