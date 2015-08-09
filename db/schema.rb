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

ActiveRecord::Schema.define(version: 20150808225455) do

  create_table "images", force: :cascade do |t|
    t.string   "caption"
    t.integer  "listing_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.integer  "user_id"
  end

  add_index "images", ["user_id"], name: "index_images_on_user_id"

  create_table "listings", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "user_id"
    t.string   "summary"
    t.integer  "listing_price_standard"
    t.string   "address"
    t.string   "country"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "city"
  end

  add_index "listings", ["user_id"], name: "index_listings_on_user_id"

  create_table "messages", force: :cascade do |t|
    t.text     "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "order_id"
    t.integer  "user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "order_price"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "listing_id"
    t.integer  "buyer_id"
    t.integer  "seller_id"
    t.string   "status"
    t.text     "message"
    t.boolean  "check_payin"
    t.boolean  "check_payout"
    t.integer  "fees_buyer"
    t.integer  "fees_seller"
    t.integer  "order_payout"
    t.integer  "mangopay_transaction_id"
    t.integer  "mangopay_payout_id"
  end

  add_index "orders", ["listing_id"], name: "index_orders_on_listing_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "last_name"
    t.string   "first_name"
    t.string   "adressline1"
    t.string   "city"
    t.string   "region"
    t.string   "postalcode"
    t.string   "country"
    t.string   "nationality"
    t.date     "birthday"
    t.string   "bic"
    t.string   "iban"
    t.integer  "mangopay_user_id"
    t.integer  "mangopay_wallet_id"
    t.integer  "mangopay_bank_id"
    t.integer  "mangopay_card_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
