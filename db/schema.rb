# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20141103181747) do

  create_table "clothing", force: true do |t|
    t.string   "name"
    t.string   "color"
    t.string   "clothing_type"
    t.string   "notes"
    t.boolean  "labeled",                         default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.float    "hue",                  limit: 24
    t.float    "saturation",           limit: 24
    t.float    "brightness",           limit: 24
    t.float    "cost",                 limit: 24
    t.date     "last_worn"
    t.integer  "clothing_logs_count",             default: 0
    t.integer  "last_clothing_log_id"
    t.integer  "user_id"
    t.string   "image_file_name"
    t.integer  "image_file_size"
    t.string   "image_content_type"
    t.datetime "image_updated_at"
  end

  add_index "clothing", ["user_id"], name: "index_clothing_on_user_id", using: :btree

  create_table "clothing_logs", force: true do |t|
    t.integer "clothing_id"
    t.date    "date"
    t.integer "outfit_id",   default: 1
    t.integer "user_id"
  end

  add_index "clothing_logs", ["user_id"], name: "index_clothing_logs_on_user_id", using: :btree

  create_table "clothing_matches", force: true do |t|
    t.integer  "clothing_a_id"
    t.integer  "clothing_b_id"
    t.integer  "clothing_log_a_id"
    t.integer  "clothing_log_b_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.date     "clothing_log_date"
  end

  add_index "clothing_matches", ["user_id"], name: "index_clothing_matches_on_user_id", using: :btree

  create_table "context_rules", force: true do |t|
    t.integer  "stuff_id"
    t.integer  "location_id"
    t.integer  "context_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contexts", force: true do |t|
    t.string   "name"
    t.text     "rules",      limit: 16777215
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "csa_foods", force: true do |t|
    t.integer  "food_id"
    t.integer  "quantity"
    t.string   "unit"
    t.string   "disposition"
    t.text     "notes",         limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "date_received"
    t.integer  "user_id"
  end

  add_index "csa_foods", ["user_id"], name: "index_csa_foods_on_user_id", using: :btree

  create_table "days", force: true do |t|
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

  add_index "days", ["user_id"], name: "index_days_on_user_id", using: :btree

  create_table "decision_logs", force: true do |t|
    t.text     "notes",       limit: 16777215
    t.text     "notes_html",  limit: 16777215
    t.date     "date"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "decision_id"
    t.integer  "user_id"
  end

  add_index "decision_logs", ["user_id"], name: "index_decision_logs_on_user_id", using: :btree

  create_table "decisions", force: true do |t|
    t.string   "name"
    t.date     "date"
    t.text     "notes",      limit: 16777215
    t.text     "notes_html", limit: 16777215
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating"
    t.integer  "user_id"
  end

  add_index "decisions", ["user_id"], name: "index_decisions_on_user_id", using: :btree

  create_table "foods", force: true do |t|
    t.string   "name"
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "foods", ["user_id"], name: "index_foods_on_user_id", using: :btree

  create_table "goals", force: true do |t|
    t.integer  "user_id"
    t.string   "label"
    t.string   "expression"
    t.string   "period"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
  end

  create_table "grocery_list_items", force: true do |t|
    t.string   "name"
    t.integer  "grocery_list_id"
    t.string   "quantity"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "receipt_item_category_id"
  end

  create_table "grocery_list_users", force: true do |t|
    t.integer  "grocery_list_id"
    t.string   "email"
    t.integer  "user_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grocery_lists", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "library_items", force: true do |t|
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
    t.text     "notes",              limit: 16777215
    t.decimal  "price",                               precision: 10, scale: 0
    t.integer  "pages"
    t.integer  "user_id"
    t.string   "details"
  end

  add_index "library_items", ["user_id"], name: "index_library_items_on_user_id", using: :btree

  create_table "links", force: true do |t|
    t.integer  "link_a_id"
    t.string   "link_a_type"
    t.integer  "link_b_id"
    t.string   "link_b_type"
    t.text     "data",        limit: 16777215
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "links", ["link_a_id", "link_a_type"], name: "index_links_on_link_a_id_and_link_a_type", using: :btree
  add_index "links", ["link_b_id", "link_b_type"], name: "index_links_on_link_b_id_and_link_b_type", using: :btree
  add_index "links", ["user_id"], name: "index_links_on_user_id", using: :btree

  create_table "location_histories", force: true do |t|
    t.integer  "stuff_id"
    t.integer  "location_id"
    t.datetime "datetime"
    t.text     "notes",       limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "location_histories", ["user_id"], name: "index_location_histories_on_user_id", using: :btree

  create_table "locations", force: true do |t|
    t.string   "name"
    t.text     "notes",      limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "locations", ["user_id"], name: "index_locations_on_user_id", using: :btree

  create_table "measurement_logs", force: true do |t|
    t.integer  "measurement_id"
    t.datetime "datetime"
    t.text     "notes",          limit: 16777215
    t.decimal  "value",                           precision: 10, scale: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "measurement_logs", ["user_id"], name: "index_measurement_logs_on_user_id", using: :btree

  create_table "measurements", force: true do |t|
    t.string   "name"
    t.text     "notes",      limit: 16777215
    t.string   "unit"
    t.decimal  "average",                     precision: 10, scale: 0
    t.decimal  "max",                         precision: 10, scale: 0
    t.decimal  "min",                         precision: 10, scale: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "sum",                         precision: 10, scale: 0
    t.integer  "user_id"
  end

  add_index "measurements", ["user_id"], name: "index_measurements_on_user_id", using: :btree

  create_table "memories", force: true do |t|
    t.string   "name"
    t.text     "body",       limit: 16777215
    t.string   "access"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "timestamp"
    t.integer  "rating"
    t.string   "date_entry"
    t.datetime "sort_time"
  end

  add_index "memories", ["name"], name: "index_memories_on_name", using: :btree
  add_index "memories", ["user_id"], name: "index_memories_on_user_id", using: :btree

  create_table "receipt_item_categories", force: true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "receipt_item_types", force: true do |t|
    t.string   "receipt_name"
    t.string   "friendly_name"
    t.integer  "user_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "receipt_item_category_id"
  end

  create_table "receipt_items", force: true do |t|
    t.integer  "user_id"
    t.string   "filename"
    t.string   "source_id"
    t.string   "source_name"
    t.string   "store"
    t.date     "date"
    t.string   "name"
    t.decimal  "quantity",             precision: 10, scale: 3
    t.string   "unit"
    t.decimal  "unit_price",           precision: 10, scale: 3
    t.decimal  "total",                precision: 10, scale: 2
    t.string   "notes"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "receipt_item_type_id"
  end

  create_table "record_categories", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "parent_id"
    t.string   "dotted_ids"
    t.string   "category_type"
    t.text     "data",          limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_name"
    t.string   "color"
    t.boolean  "active",                         default: true, null: false
  end

  add_index "record_categories", ["dotted_ids"], name: "index_record_categories_on_dotted_ids", using: :btree
  add_index "record_categories", ["name"], name: "index_record_categories_on_name", using: :btree

  create_table "records", force: true do |t|
    t.integer  "user_id"
    t.string   "source_name"
    t.integer  "source_id"
    t.datetime "timestamp"
    t.integer  "record_category_id"
    t.text     "data",               limit: 16777215
    t.datetime "end_timestamp"
    t.integer  "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "date"
    t.boolean  "manual",                              default: false
  end

  add_index "records", ["record_category_id"], name: "index_records_on_record_category_id", using: :btree
  add_index "records", ["timestamp"], name: "index_records_on_timestamp", using: :btree

  create_table "services", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "uname"
    t.string   "uemail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", force: true do |t|
    t.string   "var",                         null: false
    t.text     "value",      limit: 16777215
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "signups", force: true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stuff", force: true do |t|
    t.string   "name"
    t.string   "status"
    t.decimal  "price",                             precision: 10, scale: 0
    t.date     "purchase_date"
    t.text     "notes",            limit: 16777215
    t.string   "long_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id"
    t.integer  "home_location_id"
    t.boolean  "in_place"
    t.integer  "user_id"
    t.string   "stuff_type",                                                 default: "stuff"
  end

  add_index "stuff", ["location_id"], name: "index_stuff_on_location_id", using: :btree
  add_index "stuff", ["name", "location_id"], name: "index_stuff_on_name_and_location_id", using: :btree
  add_index "stuff", ["name"], name: "index_stuff_on_name", using: :btree
  add_index "stuff", ["user_id"], name: "index_stuff_on_user_id", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "tap_log_records", force: true do |t|
    t.integer  "user_id"
    t.integer  "tap_log_id"
    t.datetime "timestamp"
    t.string   "catOne"
    t.string   "catTwo"
    t.string   "catThree"
    t.decimal  "number",                         precision: 10, scale: 2
    t.integer  "rating"
    t.text     "note",          limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.datetime "end_timestamp"
    t.string   "entry_type"
    t.integer  "duration"
    t.string   "source"
  end

  add_index "tap_log_records", ["catOne", "catTwo", "catThree"], name: "index_tap_log_records_on_catOne_and_catTwo_and_catThree", using: :btree
  add_index "tap_log_records", ["end_timestamp"], name: "index_tap_log_records_on_end_timestamp", using: :btree
  add_index "tap_log_records", ["timestamp"], name: "index_tap_log_records_on_timestamp", using: :btree

  create_table "time_records", force: true do |t|
    t.string   "name"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "time_records", ["user_id"], name: "index_time_records_on_user_id", using: :btree

  create_table "timeline_events", force: true do |t|
    t.string   "event_type"
    t.string   "subject_type"
    t.string   "actor_type"
    t.string   "secondary_subject_type"
    t.integer  "subject_id"
    t.integer  "actor_id"
    t.integer  "secondary_subject_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "toronto_libraries", force: true do |t|
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

  add_index "toronto_libraries", ["user_id"], name: "index_toronto_libraries_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                                     default: "",    null: false
    t.string   "encrypted_password",       limit: 128,      default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                             default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "birthdate"
    t.float    "life_expectancy",          limit: 24
    t.integer  "life_expectancy_in_years"
    t.date     "projected_end"
    t.string   "role"
    t.string   "username"
    t.string   "authentication_token"
    t.text     "data",                     limit: 16777215
    t.string   "invitation_token"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.boolean  "approved",                                  default: false, null: false
    t.string   "unconfirmed_email"
    t.datetime "invitation_created_at"
    t.integer  "invitations_count",                         default: 0
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
