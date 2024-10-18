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

ActiveRecord::Schema[7.2].define(version: 2024_10_06_135521) do
  create_table "clothing", force: :cascade do |t|
    t.string "name", limit: 255
    t.string "color", limit: 255
    t.string "clothing_type", limit: 255
    t.string "notes", limit: 255
    t.integer "labeled", default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "status", limit: 255
    t.float "hue"
    t.float "saturation"
    t.float "brightness"
    t.float "cost"
    t.date "last_worn"
    t.integer "clothing_logs_count", default: 0
    t.integer "last_clothing_log_id"
    t.integer "user_id"
    t.string "image_file_name", limit: 255
    t.integer "image_file_size"
    t.string "image_content_type", limit: 255
    t.datetime "image_updated_at"
    t.index ["user_id"], name: "idx_clothing_index_clothing_on_user_id"
  end

  create_table "clothing_logs", force: :cascade do |t|
    t.integer "clothing_id"
    t.date "date"
    t.integer "outfit_id", default: 1
    t.integer "user_id"
    t.index ["user_id"], name: "idx_clothing_logs_index_clothing_logs_on_user_id"
  end

  create_table "clothing_matches", force: :cascade do |t|
    t.integer "clothing_a_id"
    t.integer "clothing_b_id"
    t.integer "clothing_log_a_id"
    t.integer "clothing_log_b_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.date "clothing_log_date"
    t.index ["user_id"], name: "idx_clothing_matches_index_clothing_matches_on_user_id"
  end

  create_table "context_rules", force: :cascade do |t|
    t.integer "stuff_id"
    t.integer "location_id"
    t.integer "context_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contexts", force: :cascade do |t|
    t.string "name", limit: 255
    t.text "rules"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "csa_foods", force: :cascade do |t|
    t.integer "food_id"
    t.integer "quantity"
    t.string "unit", limit: 255
    t.string "disposition", limit: 255
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "date_received"
    t.integer "user_id"
    t.index ["user_id"], name: "idx_csa_foods_index_csa_foods_on_user_id"
  end

  create_table "days", force: :cascade do |t|
    t.date "date"
    t.integer "temperature"
    t.string "clothing_temperature", limit: 255
    t.integer "library_checked_out"
    t.integer "library_pickup"
    t.integer "library_transit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.index ["user_id"], name: "idx_days_index_days_on_user_id"
  end

  create_table "decision_logs", force: :cascade do |t|
    t.text "notes"
    t.text "notes_html"
    t.date "date"
    t.string "status", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "decision_id"
    t.integer "user_id"
    t.index ["user_id"], name: "idx_decision_logs_index_decision_logs_on_user_id"
  end

  create_table "decisions", force: :cascade do |t|
    t.string "name", limit: 255
    t.date "date"
    t.text "notes"
    t.text "notes_html"
    t.string "status", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "rating"
    t.integer "user_id"
    t.index ["user_id"], name: "idx_decisions_index_decisions_on_user_id"
  end

  create_table "foods", force: :cascade do |t|
    t.string "name", limit: 255
    t.string "notes", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.index ["user_id"], name: "idx_foods_index_foods_on_user_id"
  end

  create_table "goals", force: :cascade do |t|
    t.integer "user_id"
    t.string "label", limit: 255
    t.string "expression", limit: 255
    t.string "period", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "status", limit: 255
  end

  create_table "grocery_list_items", force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "grocery_list_id"
    t.string "quantity", limit: 255
    t.string "status", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "receipt_item_category_id"
  end

  create_table "grocery_list_users", force: :cascade do |t|
    t.integer "grocery_list_id"
    t.string "email", limit: 255
    t.integer "user_id"
    t.string "status", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grocery_lists", force: :cascade do |t|
    t.integer "user_id"
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "library_items", force: :cascade do |t|
    t.string "library_id", limit: 255
    t.string "dewey", limit: 255
    t.string "title", limit: 255
    t.string "author", limit: 255
    t.date "due"
    t.integer "rating"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "status", limit: 255
    t.date "checkout_date"
    t.date "return_date"
    t.date "read_date"
    t.integer "toronto_library_id"
    t.string "isbn", limit: 255
    t.integer "public"
    t.text "notes"
    t.decimal "price", precision: 10
    t.integer "pages"
    t.integer "user_id"
    t.string "details", limit: 255
    t.index ["user_id"], name: "idx_library_items_index_library_items_on_user_id"
  end

  create_table "links", force: :cascade do |t|
    t.integer "link_a_id"
    t.string "link_a_type", limit: 255
    t.integer "link_b_id"
    t.string "link_b_type", limit: 255
    t.text "data"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["link_a_id", "link_a_type"], name: "idx_links_index_links_on_link_a_id_and_link_a_type"
    t.index ["link_b_id", "link_b_type"], name: "idx_links_index_links_on_link_b_id_and_link_b_type"
    t.index ["user_id"], name: "idx_links_index_links_on_user_id"
  end

  create_table "location_histories", force: :cascade do |t|
    t.integer "stuff_id"
    t.integer "location_id"
    t.datetime "datetime"
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.index ["user_id"], name: "idx_location_histories_index_location_histories_on_user_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name", limit: 255
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.index ["user_id"], name: "idx_locations_index_locations_on_user_id"
  end

  create_table "measurement_logs", force: :cascade do |t|
    t.integer "measurement_id"
    t.datetime "datetime"
    t.text "notes"
    t.decimal "value", precision: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.index ["user_id"], name: "idx_measurement_logs_index_measurement_logs_on_user_id"
  end

  create_table "measurements", force: :cascade do |t|
    t.string "name", limit: 255
    t.text "notes"
    t.string "unit", limit: 255
    t.decimal "average", precision: 10
    t.decimal "max", precision: 10
    t.decimal "min", precision: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "sum", precision: 10
    t.integer "user_id"
    t.index ["user_id"], name: "idx_measurements_index_measurements_on_user_id"
  end

  create_table "memories", force: :cascade do |t|
    t.string "name", limit: 255
    t.text "body"
    t.string "access", limit: 255
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "timestamp"
    t.integer "rating"
    t.string "date_entry", limit: 255
    t.datetime "sort_time"
    t.index ["name"], name: "idx_memories_index_memories_on_name"
    t.index ["user_id"], name: "idx_memories_index_memories_on_user_id"
  end

  create_table "receipt_item_categories", force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "receipt_item_types", force: :cascade do |t|
    t.string "receipt_name", limit: 255
    t.string "friendly_name", limit: 255
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "receipt_item_category_id"
  end

  create_table "receipt_items", force: :cascade do |t|
    t.integer "user_id"
    t.string "filename", limit: 255
    t.string "source_id", limit: 255
    t.string "source_name", limit: 255
    t.string "store", limit: 255
    t.date "date"
    t.string "name", limit: 255
    t.decimal "quantity", precision: 10, scale: 3
    t.string "unit", limit: 255
    t.decimal "unit_price", precision: 10, scale: 3
    t.decimal "total", precision: 10, scale: 2
    t.string "notes", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "receipt_item_type_id"
  end

  create_table "record_categories", force: :cascade do |t|
    t.integer "user_id"
    t.string "name", limit: 255
    t.integer "parent_id"
    t.string "dotted_ids", limit: 255
    t.string "category_type", limit: 255
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "full_name", limit: 255
    t.string "color", limit: 255
    t.integer "active", default: 1, null: false
    t.string "ancestry"
    t.index ["ancestry"], name: "index_record_categories_on_ancestry"
    t.index ["dotted_ids"], name: "idx_record_categories_index_record_categories_on_dotted_ids"
    t.index ["name"], name: "idx_record_categories_index_record_categories_on_name"
  end

  create_table "records", force: :cascade do |t|
    t.integer "user_id"
    t.string "source_name", limit: 255
    t.integer "source_id"
    t.datetime "timestamp"
    t.integer "record_category_id"
    t.text "data"
    t.datetime "end_timestamp"
    t.integer "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "date"
    t.integer "manual", default: 0
    t.index ["record_category_id"], name: "idx_records_index_records_on_record_category_id"
    t.index ["timestamp"], name: "idx_records_index_records_on_timestamp"
  end

  create_table "services", force: :cascade do |t|
    t.integer "user_id"
    t.string "provider", limit: 255
    t.string "uid", limit: 255
    t.string "uname", limit: 255
    t.string "uemail", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "signups", force: :cascade do |t|
    t.string "email", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "stuff", force: :cascade do |t|
    t.string "name", limit: 255
    t.string "status", limit: 255
    t.decimal "price", precision: 10
    t.date "purchase_date"
    t.text "notes"
    t.string "long_name", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "location_id"
    t.integer "home_location_id"
    t.integer "in_place"
    t.integer "user_id"
    t.string "stuff_type", limit: 255, default: "stuff"
    t.index ["location_id"], name: "idx_stuff_index_stuff_on_location_id"
    t.index ["name", "location_id"], name: "idx_stuff_index_stuff_on_name_and_location_id"
    t.index ["name"], name: "idx_stuff_index_stuff_on_name"
    t.index ["user_id"], name: "idx_stuff_index_stuff_on_user_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string "taggable_type", limit: 255
    t.integer "tagger_id"
    t.string "tagger_type", limit: 255
    t.string "context", limit: 255
    t.datetime "created_at", precision: nil
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "taggings_count", default: 0
  end

  create_table "tap_log_records", force: :cascade do |t|
    t.integer "user_id"
    t.integer "tap_log_id"
    t.datetime "timestamp", precision: nil
    t.string "catOne", limit: 255
    t.string "catTwo", limit: 255
    t.string "catThree", limit: 255
    t.decimal "number", precision: 10, scale: 2
    t.integer "rating"
    t.text "note"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "status", limit: 255
    t.datetime "end_timestamp", precision: nil
    t.string "entry_type", limit: 255
    t.integer "duration"
    t.string "source", limit: 255
  end

  create_table "time_records", force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "start_time", precision: nil
    t.datetime "end_time", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.index ["user_id"], name: "idx_time_records_index_time_records_on_user_id"
  end

  create_table "timeline_events", force: :cascade do |t|
    t.string "event_type", limit: 255
    t.string "subject_type", limit: 255
    t.string "actor_type", limit: 255
    t.string "secondary_subject_type", limit: 255
    t.integer "subject_id"
    t.integer "actor_id"
    t.integer "secondary_subject_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "toronto_libraries", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "name", limit: 255
    t.string "card", limit: 255
    t.string "pin", limit: 255
    t.date "last_checked"
    t.integer "pickup_count"
    t.integer "library_item_count"
    t.integer "user_id"
    t.index ["user_id"], name: "idx_toronto_libraries_index_toronto_libraries_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 128, default: ""
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.date "birthdate"
    t.float "life_expectancy"
    t.integer "life_expectancy_in_years"
    t.date "projected_end"
    t.string "role", limit: 255
    t.string "username", limit: 255
    t.string "authentication_token", limit: 255
    t.text "data"
    t.string "invitation_token", limit: 60
    t.datetime "invitation_sent_at", precision: nil
    t.datetime "invitation_accepted_at", precision: nil
    t.integer "invitation_limit"
    t.integer "invited_by_id"
    t.string "invited_by_type", limit: 255
    t.string "confirmation_token", limit: 255
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.integer "approved", default: 0, null: false
    t.string "unconfirmed_email", limit: 255
    t.index ["invitation_token"], name: "idx_users_index_users_on_invitation_token"
    t.index ["invited_by_id"], name: "idx_users_index_users_on_invited_by_id"
  end
end
