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

ActiveRecord::Schema.define(version: 20190228114846) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"
  enable_extension "uuid-ossp"

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "attachments", force: :cascade do |t|
    t.string "file_id"
    t.string "file_filename"
    t.string "file_content_type"
    t.string "place"
    t.integer "peoples", array: true
    t.string "able_type"
    t.integer "able_id"
    t.string "caption"
    t.decimal "lat", precision: 11, scale: 7
    t.decimal "long", precision: 11, scale: 7
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "trip_id"
    t.string "type"
    t.integer "location_id"
    t.integer "likes", default: [], array: true
    t.bigint "uploaded_at"
    t.string "place_id"
    t.string "place_type"
    t.integer "upload_by"
  end

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.string "country"
    t.integer "trip_id"
    t.decimal "lat"
    t.decimal "long"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "start_date"
    t.bigint "end_date"
    t.integer "user_id"
    t.integer "like", default: [], array: true
    t.string "city"
    t.index ["trip_id", "country", "name"], name: "index_cities_on_trip_id_and_country_and_name", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.integer "user_id"
    t.integer "comment_able_id"
    t.string "comment_able_type"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contacts", force: :cascade do |t|
    t.integer "user_id"
    t.string "contact"
    t.integer "contact_type"
    t.boolean "has_contact", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "friendships", force: :cascade do |t|
    t.string "friendable_type"
    t.bigint "friendable_id"
    t.integer "friend_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "blocker_id"
    t.integer "status"
    t.index ["friendable_type", "friendable_id"], name: "index_friendships_on_friendable_type_and_friendable_id"
  end

  create_table "invites", force: :cascade do |t|
    t.string "contact"
    t.string "country"
    t.bigint "invited_at"
    t.bigint "accept_invite_at"
    t.string "token"
    t.integer "sent_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "dynamic_link"
    t.index ["token"], name: "index_invites_on_token", unique: true
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.text "note"
    t.integer "pemark"
    t.integer "trip_id"
    t.integer "city_id"
    t.string "city_name"
    t.integer "rate"
    t.decimal "lat", precision: 10, scale: 6
    t.decimal "long", precision: 10, scale: 6
    t.bigint "start_day"
    t.bigint "end_day"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "start_date"
    t.bigint "end_date"
    t.string "item_id"
  end

  create_table "notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "message_id"
    t.string "device_id"
    t.string "device"
    t.integer "user_id"
    t.string "event"
    t.jsonb "responds"
    t.jsonb "body"
    t.bigint "sent_at"
    t.bigint "read_at"
    t.jsonb "setting"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "sending"
    t.jsonb "obj", default: {}
    t.string "model_type"
    t.string "noti_type"
    t.integer "sender_id"
    t.string "title"
    t.boolean "is_unread", default: true
    t.boolean "is_hidden", default: false
    t.integer "able_id"
    t.string "able_type"
    t.boolean "is_delete", default: false
  end

  create_table "posts", force: :cascade do |t|
    t.string "post_type"
    t.string "title"
    t.integer "created_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "lat", precision: 10, scale: 6
    t.decimal "long", precision: 10, scale: 6
    t.string "activity_type"
    t.integer "activity_id"
    t.jsonb "obj"
    t.integer "total_comment"
    t.integer "total_like"
    t.integer "likes", array: true
    t.integer "stamp_ids", array: true
    t.integer "user_may_see", default: [], array: true
    t.integer "trip_id"
  end

  create_table "stamps", force: :cascade do |t|
    t.string "country"
    t.string "image_id"
    t.string "image_filename"
    t.integer "user_id"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "uploaded_at"
  end

  create_table "todo_lists", force: :cascade do |t|
    t.string "todo"
    t.integer "trip_id"
    t.decimal "lat", precision: 10, scale: 6
    t.decimal "long", precision: 10, scale: 6
    t.date "create_date"
    t.integer "is_delete"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "from_date"
    t.date "to_date"
  end

  create_table "trips", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.jsonb "trip_schedule"
    t.string "cover_picture_id"
    t.string "cover_picture_filename"
    t.integer "cover_picture_size"
    t.decimal "lat", precision: 10, scale: 6
    t.decimal "long", precision: 10, scale: 6
    t.integer "created_by"
    t.bigint "start_date"
    t.bigint "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_like"
    t.integer "total_comment"
    t.index ["trip_schedule"], name: "index_trips_on_trip_schedule", using: :gin
  end

  create_table "user_trips", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "trip_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.string "user_type"
    t.index ["trip_id"], name: "index_user_trips_on_trip_id"
    t.index ["user_id"], name: "index_user_trips_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.string "name"
    t.string "gender"
    t.string "contact"
    t.string "oauth_token"
    t.datetime "oauth_expires_at"
    t.string "country"
    t.string "image"
    t.string "email"
    t.string "fb_id"
    t.string "image_url"
    t.string "profile_picture_id"
    t.string "profile_picture_filename"
    t.integer "profile_picture_size"
    t.datetime "birthday"
    t.string "verification_code"
    t.boolean "verified"
    t.jsonb "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "device_tokens", default: []
    t.string "otp_secret"
    t.jsonb "setting"
    t.string "cover_picture_id"
    t.string "cover_picture_filename"
    t.integer "cover_picture_size"
    t.integer "push_badge", default: 1
    t.string "auth_token"
    t.string "city"
    t.index ["device_tokens"], name: "index_users_on_device_tokens", using: :gin
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["tokens"], name: "index_users_on_tokens", using: :gin
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "attachments", "trips"
  add_foreign_key "cities", "trips"
  add_foreign_key "cities", "users"
  add_foreign_key "contacts", "users"
  add_foreign_key "invites", "users", column: "sent_by"
  add_foreign_key "posts", "users", column: "created_by"
  add_foreign_key "stamps", "users"
  add_foreign_key "todo_lists", "trips"
  add_foreign_key "trips", "users", column: "created_by"
  add_foreign_key "user_trips", "trips"
  add_foreign_key "user_trips", "users"
end
