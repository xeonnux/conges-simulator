class CreateLeavePeriods < ActiveRecord::Migration[8.1]
  def change
    create_table :leave_periods do |t|
      t.references :simulation, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.decimal :months_worked, precision: 6, scale: 4
      t.decimal :days_acquired, precision: 6, scale: 4
      t.decimal :maintien_value, precision: 10, scale: 2
      t.decimal :ten_percent_value, precision: 10, scale: 2
      t.decimal :leave_value, precision: 10, scale: 2

      t.timestamps
    end
  end
end
