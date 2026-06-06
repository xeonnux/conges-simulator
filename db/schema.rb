# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_06_070053) do
  create_table "leave_periods", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "days_acquired", precision: 6, scale: 4
    t.date "end_date"
    t.decimal "leave_value", precision: 10, scale: 2
    t.decimal "maintien_value", precision: 10, scale: 2
    t.decimal "months_worked", precision: 6, scale: 4
    t.bigint "simulation_id", null: false
    t.date "start_date"
    t.decimal "ten_percent_value", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["simulation_id"], name: "index_leave_periods_on_simulation_id"
  end

  create_table "month_entries", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "gross_salary", precision: 10, scale: 2
    t.decimal "leave_mode_a", precision: 10, scale: 2
    t.decimal "leave_mode_b", precision: 10, scale: 2
    t.decimal "leave_mode_c", precision: 10, scale: 2
    t.bigint "leave_period_id", null: false
    t.integer "month"
    t.decimal "prorata", precision: 6, scale: 4
    t.bigint "simulation_id", null: false
    t.datetime "updated_at", null: false
    t.integer "year"
    t.index ["leave_period_id"], name: "index_month_entries_on_leave_period_id"
    t.index ["simulation_id"], name: "index_month_entries_on_simulation_id"
  end

  create_table "simulations", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "end_date"
    t.decimal "monthly_salary", precision: 8, scale: 2
    t.date "start_date"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "leave_periods", "simulations"
  add_foreign_key "month_entries", "leave_periods"
  add_foreign_key "month_entries", "simulations"
end
