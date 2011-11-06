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

ActiveRecord::Schema.define(:version => 20111104102959) do

  create_table "books", :force => true do |t|
    t.string   "title"
    t.string   "library_code"
    t.date     "due_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
  end

  create_table "clothing_logs", :force => true do |t|
    t.integer "clothing_id"
    t.date    "date"
    t.integer "outfit_id",   :default => 1
  end

  create_table "clothing_matches", :id => false, :force => true do |t|
    t.integer  "clothing_a_id"
    t.integer  "clothing_b_id"
    t.integer  "clothing_log_a_id"
    t.integer  "clothing_log_b_id"
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
  end

  create_table "days", :force => true do |t|
    t.date     "date"
    t.integer  "temperature"
    t.string   "clothing_temperature"
    t.integer  "library_checked_out"
    t.integer  "library_pickup"
    t.integer  "library_transit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "decision_logs", :force => true do |t|
    t.text     "notes"
    t.text     "notes_html"
    t.date     "date"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "decision_id"
  end

  create_table "decisions", :force => true do |t|
    t.string   "name"
    t.date     "date"
    t.text     "notes"
    t.text     "notes_html"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating"
  end

  create_table "foods", :force => true do |t|
    t.string   "name"
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.decimal  "price"
    t.integer  "pages"
  end

  create_table "location_histories", :force => true do |t|
    t.integer  "stuff_id"
    t.integer  "location_id"
    t.string   "location_type"
    t.datetime "datetime"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "measurement_logs", :force => true do |t|
    t.integer  "measurement_id"
    t.datetime "datetime"
    t.text     "notes"
    t.decimal  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "measurements", :force => true do |t|
    t.string   "name"
    t.text     "notes"
    t.string   "unit"
    t.decimal  "average"
    t.decimal  "max"
    t.decimal  "min"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "sum"
  end

  create_table "stuff", :force => true do |t|
    t.string   "name"
    t.string   "status"
    t.decimal  "price"
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
  end

  add_index "stuff", ["location_id"], :name => "index_stuff_on_location_id"
  add_index "stuff", ["name", "location_id"], :name => "index_stuff_on_name_and_location_id"
  add_index "stuff", ["name"], :name => "index_stuff_on_name"

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
  end

  create_table "toronto_libraries", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "card"
    t.string   "pin"
    t.date     "last_checked"
    t.integer  "pickup_count"
    t.integer  "library_item_count"
  end

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
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
