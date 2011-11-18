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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111110021956) do

  create_table "clothing", :force => true do |t|
    t.string   "name"
    t.string   "colour"
    t.string   "clothing_type"
    t.string   "notes"
    t.boolean  "labeled",              :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.float    "hue"
    t.float    "saturation"
    t.float    "brightness"
    t.float    "cost"
    t.date     "last_worn"
    t.integer  "clothing_logs_count",  :default => 0
    t.integer  "last_clothing_log_id"
    t.integer  "user_id"
  end

  add_index "clothing", ["user_id"], :name => "index_clothing_on_user_id"

  create_table "clothing_logs", :force => true do |t|
    t.integer "clothing_id"
    t.date    "date"
    t.integer "outfit_id",   :default => 1
    t.integer "user_id"
  end

  add_index "clothing_logs", ["user_id"], :name => "index_clothing_logs_on_user_id"

  create_table "clothing_matches", :id => false, :force => true do |t|
    t.integer  "clothing_a_id"
    t.integer  "clothing_b_id"
    t.integer  "clothing_log_a_id"
    t.integer  "clothing_log_b_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "clothing_matches", ["user_id"], :name => "index_clothing_matches_on_user_id"

  create_table "contexts", :force => true do |t|
    t.string   "name"
    t.text     "rules"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "csa_foods", :force => true do |t|
    t.integer  "food_id"
    t.integer  "quantity"
    t.string   "unit"
    t.string   "disposition"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "date_received"
    t.integer  "user_id"
  end

  add_index "csa_foods", ["user_id"], :name => "index_csa_foods_on_user_id"

  create_table "days", :force => true do |t|
    t.date     "date"
    t.integer  "temperature"
    t.string   "clothing_temperature"
    t.integer  "library_checked_out"
    t.integer  "library_pickup"
    t.integer  "library_transit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "days", ["user_id"], :name => "index_days_on_user_id"

  create_table "decision_logs", :force => true do |t|
    t.text     "notes"
    t.text     "notes_html"
    t.date     "date"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "decision_id"
    t.integer  "user_id"
  end

  add_index "decision_logs", ["user_id"], :name => "index_decision_logs_on_user_id"

  create_table "decisions", :force => true do |t|
    t.string   "name"
    t.date     "date"
    t.text     "notes"
    t.text     "notes_html"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating"
    t.integer  "user_id"
  end

  add_index "decisions", ["user_id"], :name => "index_decisions_on_user_id"

  create_table "foods", :force => true do |t|
    t.string   "name"
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "foods", ["user_id"], :name => "index_foods_on_user_id"

  create_table "library_items", :force => true do |t|
    t.string   "library_id"
    t.string   "dewey"
    t.string   "title"
    t.string   "author"
    t.date     "due"
    t.integer  "rating"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.date     "checkout_date"
    t.date     "return_date"
    t.date     "read_date"
    t.integer  "toronto_library_id"
    t.string   "isbn"
    t.boolean  "public"
    t.text     "notes"
    t.decimal  "price",              :precision => 10, :scale => 0
    t.integer  "pages"
    t.integer  "user_id"
  end

  add_index "library_items", ["user_id"], :name => "index_library_items_on_user_id"

  create_table "location_histories", :force => true do |t|
    t.integer  "stuff_id"
    t.integer  "location_id"
    t.string   "location_type"
    t.datetime "datetime"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "location_histories", ["user_id"], :name => "index_location_histories_on_user_id"

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "locations", ["user_id"], :name => "index_locations_on_user_id"

  create_table "measurement_logs", :force => true do |t|
    t.integer  "measurement_id"
    t.datetime "datetime"
    t.text     "notes"
    t.decimal  "value",          :precision => 10, :scale => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "measurement_logs", ["user_id"], :name => "index_measurement_logs_on_user_id"

  create_table "measurements", :force => true do |t|
    t.string   "name"
    t.text     "notes"
    t.string   "unit"
    t.decimal  "average",    :precision => 10, :scale => 0
    t.decimal  "max",        :precision => 10, :scale => 0
    t.decimal  "min",        :precision => 10, :scale => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "sum",        :precision => 10, :scale => 0
    t.integer  "user_id"
  end

  add_index "measurements", ["user_id"], :name => "index_measurements_on_user_id"

  create_table "settings", :force => true do |t|
    t.string   "var",                      :null => false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", :limit => 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], :name => "index_settings_on_thing_type_and_thing_id_and_var", :unique => true

  create_table "stuff", :force => true do |t|
    t.string   "name"
    t.string   "status"
    t.decimal  "price",              :precision => 10, :scale => 0
    t.date     "purchase_date"
    t.text     "notes"
    t.string   "long_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id"
    t.string   "location_type"
    t.integer  "home_location_id"
    t.string   "home_location_type"
    t.boolean  "in_place"
    t.integer  "user_id"
  end

  add_index "stuff", ["location_id"], :name => "index_stuff_on_location_id"
  add_index "stuff", ["name", "location_id"], :name => "index_stuff_on_name_and_location_id"
  add_index "stuff", ["name"], :name => "index_stuff_on_name"
  add_index "stuff", ["user_id"], :name => "index_stuff_on_user_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "time_records", :force => true do |t|
    t.string   "name"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "time_records", ["user_id"], :name => "index_time_records_on_user_id"

  create_table "toronto_libraries", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "card"
    t.string   "pin"
    t.date     "last_checked"
    t.integer  "pickup_count"
    t.integer  "library_item_count"
    t.integer  "user_id"
  end

  add_index "toronto_libraries", ["user_id"], :name => "index_toronto_libraries_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                   :default => "", :null => false
    t.string   "encrypted_password",       :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                           :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "birthdate"
    t.float    "life_expectancy"
    t.integer  "life_expectancy_in_years"
    t.date     "projected_end"
    t.string   "role"
    t.string   "username"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
