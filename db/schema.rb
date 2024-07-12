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

ActiveRecord::Schema[7.1].define(version: 2024_03_11_032520) do
  create_table "accounts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "investec_id"
    t.string "ynab_id"
    t.index ["number"], name: "index_accounts_on_number", unique: true
  end

  create_table "cards", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "investec_id", null: false
    t.string "number", null: false
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_cards_on_account_id"
    t.index ["investec_id"], name: "index_cards_on_investec_id", unique: true
    t.index ["number"], name: "index_cards_on_number", unique: true
  end

  create_table "countries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "alpha3"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_countries_on_code", unique: true
  end

  create_table "merchant_categories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "code", null: false
    t.string "key", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_merchant_categories_on_code", unique: true
  end

  create_table "merchants", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "city"
    t.bigint "country_id", null: false
    t.bigint "merchant_category_id", null: false
    t.bigint "ynab_payee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "exclude_from_ynab_mapping", default: false
    t.index ["country_id"], name: "index_merchants_on_country_id"
    t.index ["merchant_category_id"], name: "index_merchants_on_merchant_category_id"
    t.index ["name"], name: "index_merchants_on_name", unique: true
    t.index ["ynab_payee_id"], name: "index_merchants_on_ynab_payee_id"
  end

  create_table "transactions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.decimal "amount_cents", precision: 21, scale: 3, null: false
    t.string "currency", limit: 3, null: false
    t.datetime "transaction_date", null: false
    t.bigint "merchant_id"
    t.string "reference"
    t.string "transaction_type"
    t.bigint "card_id"
    t.string "ynab_import_id"
    t.boolean "is_cleared", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["card_id"], name: "index_transactions_on_card_id"
    t.index ["merchant_id"], name: "index_transactions_on_merchant_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ynab_payees", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "ynab_id", limit: 36
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ynab_id"], name: "index_ynab_payees_on_ynab_id", unique: true
  end

end
