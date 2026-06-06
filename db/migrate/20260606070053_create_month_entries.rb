class CreateMonthEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :month_entries do |t|
      t.references :simulation, null: false, foreign_key: true
      t.references :leave_period, null: false, foreign_key: true
      t.integer :year
      t.integer :month
      t.decimal :prorata, precision: 6, scale: 4
      t.decimal :gross_salary, precision: 10, scale: 2
      t.decimal :leave_mode_a, precision: 10, scale: 2
      t.decimal :leave_mode_b, precision: 10, scale: 2
      t.decimal :leave_mode_c, precision: 10, scale: 2

      t.timestamps
    end
  end
end
