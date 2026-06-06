class MonthEntry < ApplicationRecord
  belongs_to :simulation
  belongs_to :leave_period
end
