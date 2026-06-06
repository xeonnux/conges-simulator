class Simulation < ApplicationRecord
  has_many :leave_periods, dependent: :destroy
  has_many :month_entries, dependent: :destroy

  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :monthly_salary, presence: true,
            numericality: { greater_than_or_equal_to: 200, less_than_or_equal_to: 1200 }

  validate :end_date_after_start_date

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?

    if end_date <= start_date
      errors.add(:end_date, "doit être postérieure à la date de début")
    end
  end
end
