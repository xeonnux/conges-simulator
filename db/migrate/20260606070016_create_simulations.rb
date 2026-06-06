class CreateSimulations < ActiveRecord::Migration[8.1]
  def change
    create_table :simulations do |t|
      t.date :start_date
      t.date :end_date
      t.decimal :monthly_salary, precision: 8, scale: 2

      t.timestamps
    end
  end
end
