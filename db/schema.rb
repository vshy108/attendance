# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_02_25_150523) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "default_templates", force: :cascade do |t|
    t.bigint "working_template_id"
    t.bigint "worker_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "valid_before_date"
    t.index ["valid_before_date", "worker_id"], name: "index_default_templates_on_valid_before_date_and_worker_id", unique: true
    t.index ["worker_id"], name: "index_default_templates_on_worker_id"
    t.index ["working_template_id"], name: "index_default_templates_on_working_template_id"
  end

  create_table "holidays", force: :cascade do |t|
    t.date "valid_date"
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["valid_date"], name: "index_holidays_on_valid_date", unique: true
  end

  create_table "overtime_configs", force: :cascade do |t|
    t.bigint "working_template_id"
    t.string "overtime_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["working_template_id"], name: "index_overtime_configs_on_working_template_id"
  end

  create_table "punch_times", force: :cascade do |t|
    t.datetime "punched_datetime"
    t.bigint "worker_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "working_day_id"
    t.bigint "uncertain_working_day_id"
    t.index ["uncertain_working_day_id"], name: "index_punch_times_on_uncertain_working_day_id"
    t.index ["worker_id", "punched_datetime"], name: "index_punch_times_on_worker_id_and_punched_datetime", unique: true
    t.index ["worker_id"], name: "index_punch_times_on_worker_id"
    t.index ["working_day_id"], name: "index_punch_times_on_working_day_id"
  end

  create_table "repeat_template_parts", force: :cascade do |t|
    t.date "first_repeat_date"
    t.bigint "repeat_template_id"
    t.bigint "working_template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["repeat_template_id", "first_repeat_date"], name: "by_repeat_date_in_template", unique: true
    t.index ["repeat_template_id"], name: "index_repeat_template_parts_on_repeat_template_id"
    t.index ["working_template_id"], name: "index_repeat_template_parts_on_working_template_id"
  end

  create_table "repeat_templates", force: :cascade do |t|
    t.integer "repeat_day_difference"
    t.bigint "worker_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["worker_id"], name: "index_repeat_templates_on_worker_id", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.integer "thing_id"
    t.string "thing_type", limit: 30
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "username", default: "", null: false
    t.string "name", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.text "tokens"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "valid_work_sections", force: :cascade do |t|
    t.integer "from_time_in_minute"
    t.integer "to_time_in_minute"
    t.bigint "working_template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["working_template_id"], name: "index_valid_work_sections_on_working_template_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "workers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "overtime_value", precision: 5, scale: 2
  end

  create_table "working_days", force: :cascade do |t|
    t.date "working_date"
    t.bigint "working_template_id"
    t.bigint "worker_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["worker_id"], name: "index_working_days_on_worker_id"
    t.index ["working_date", "worker_id"], name: "index_working_days_on_working_date_and_worker_id", unique: true
    t.index ["working_template_id"], name: "index_working_days_on_working_template_id"
  end

  create_table "working_templates", force: :cascade do |t|
    t.string "name"
    t.integer "override_working_minutes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_working_templates_on_name", unique: true
  end

  create_table "year_leave_limits", force: :cascade do |t|
    t.integer "year_number"
    t.integer "allowed_annual_days_total"
    t.bigint "worker_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["worker_id", "year_number"], name: "index_year_leave_limits_on_worker_id_and_year_number", unique: true
    t.index ["worker_id"], name: "index_year_leave_limits_on_worker_id"
  end

  add_foreign_key "default_templates", "workers"
  add_foreign_key "default_templates", "working_templates"
  add_foreign_key "overtime_configs", "working_templates"
  add_foreign_key "punch_times", "workers"
  add_foreign_key "punch_times", "working_days"
  add_foreign_key "punch_times", "working_days", column: "uncertain_working_day_id"
  add_foreign_key "repeat_template_parts", "repeat_templates"
  add_foreign_key "repeat_template_parts", "working_templates"
  add_foreign_key "repeat_templates", "workers"
  add_foreign_key "valid_work_sections", "working_templates"
  add_foreign_key "working_days", "workers"
  add_foreign_key "working_days", "working_templates"
  add_foreign_key "year_leave_limits", "workers"
end
