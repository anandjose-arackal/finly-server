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

ActiveRecord::Schema.define(version: 20170817121335) do

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace",     limit: 255
    t.text     "body",          limit: 65535
    t.string   "resource_id",   limit: 255,   null: false
    t.string   "resource_type", limit: 255,   null: false
    t.integer  "author_id",     limit: 4
    t.string   "author_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_review_workflow_levels", force: :cascade do |t|
    t.integer  "admin_review_workflow_id", limit: 4,                 null: false
    t.integer  "position",                 limit: 4,                 null: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.boolean  "trigger_email",                      default: false, null: false
    t.boolean  "reviewer",                           default: false, null: false
    t.integer  "admin_user_id",            limit: 4,                 null: false
    t.datetime "email_triggered_at"
  end

  add_index "admin_review_workflow_levels", ["admin_review_workflow_id"], name: "index_admin_review_workflow_levels_on_admin_review_workflow_id", using: :btree
  add_index "admin_review_workflow_levels", ["position"], name: "index_admin_review_workflow_levels_on_position", using: :btree

  create_table "admin_review_workflows", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "admin_review_workflows", ["name"], name: "index_admin_review_workflows_on_name", using: :btree

  create_table "admin_user_role_mappings", force: :cascade do |t|
    t.integer  "admin_user_id",      limit: 4
    t.integer  "admin_user_role_id", limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "admin_user_role_mappings", ["admin_user_id"], name: "index_admin_user_role_mappings_on_admin_user_id", using: :btree
  add_index "admin_user_role_mappings", ["admin_user_role_id"], name: "index_admin_user_role_mappings_on_admin_user_role_id", using: :btree

  create_table "admin_user_roles", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "mobile_number",          limit: 255,              null: false
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "agreement_types", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "agreements", force: :cascade do |t|
    t.integer  "agreement_type_id", limit: 4,                   null: false
    t.string   "file_file_name",    limit: 255,                 null: false
    t.string   "file_content_type", limit: 255,                 null: false
    t.integer  "file_file_size",    limit: 4,                   null: false
    t.datetime "file_updated_at",                               null: false
    t.string   "version",           limit: 255,                 null: false
    t.boolean  "active",                        default: false, null: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "url",               limit: 255
  end

  add_index "agreements", ["agreement_type_id"], name: "index_agreements_on_agreement_type_id", using: :btree

  create_table "amounts", force: :cascade do |t|
    t.decimal  "value",                 precision: 64, scale: 12
    t.integer  "currency_id", limit: 4,                                           null: false
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.decimal  "INR",                   precision: 20, scale: 5
    t.decimal  "USD",                   precision: 20, scale: 5
    t.decimal  "GBP",                   precision: 20, scale: 5
    t.decimal  "CAD",                   precision: 20, scale: 5
    t.decimal  "EUR",                   precision: 20, scale: 5
    t.decimal  "HRK",                   precision: 20, scale: 5
    t.decimal  "RUB",                   precision: 20, scale: 5
    t.decimal  "BGN",                   precision: 20, scale: 5
    t.decimal  "BRL",                   precision: 20, scale: 5
    t.decimal  "CHF",                   precision: 20, scale: 5
    t.decimal  "CNY",                   precision: 20, scale: 5
    t.decimal  "CZK",                   precision: 20, scale: 5
    t.decimal  "DKK",                   precision: 20, scale: 5
    t.decimal  "HKD",                   precision: 20, scale: 5
    t.decimal  "HUF",                   precision: 20, scale: 5
    t.decimal  "IDR",                   precision: 20, scale: 5
    t.decimal  "ILS",                   precision: 20, scale: 5
    t.decimal  "JPY",                   precision: 20, scale: 5
    t.decimal  "KRW",                   precision: 20, scale: 5
    t.decimal  "MXN",                   precision: 20, scale: 5
    t.decimal  "NOK",                   precision: 20, scale: 5
    t.decimal  "NZD",                   precision: 20, scale: 5
    t.decimal  "PHP",                   precision: 20, scale: 5
    t.decimal  "PLN",                   precision: 20, scale: 5
    t.decimal  "RON",                   precision: 20, scale: 5
    t.decimal  "SEK",                   precision: 20, scale: 5
    t.decimal  "SGD",                   precision: 20, scale: 5
    t.decimal  "THB",                   precision: 20, scale: 5
    t.decimal  "TRY",                   precision: 20, scale: 5
    t.decimal  "ZAR",                   precision: 20, scale: 5
    t.decimal  "AUD",                   precision: 20, scale: 5
    t.decimal  "AED",                   precision: 20, scale: 5
    t.decimal  "AFN",                   precision: 20, scale: 5
    t.decimal  "ALL",                   precision: 20, scale: 5
    t.decimal  "AMD",                   precision: 20, scale: 5
    t.decimal  "ANG",                   precision: 20, scale: 5
    t.decimal  "AOA",                   precision: 20, scale: 5
    t.decimal  "ARS",                   precision: 20, scale: 5
    t.decimal  "AWG",                   precision: 20, scale: 5
    t.decimal  "AZN",                   precision: 20, scale: 5
    t.decimal  "BAM",                   precision: 20, scale: 5
    t.decimal  "BBD",                   precision: 20, scale: 5
    t.decimal  "BDT",                   precision: 20, scale: 5
    t.decimal  "BHD",                   precision: 20, scale: 5
    t.decimal  "BIF",                   precision: 20, scale: 5
    t.decimal  "BMD",                   precision: 20, scale: 5
    t.decimal  "BND",                   precision: 20, scale: 5
    t.decimal  "BOB",                   precision: 20, scale: 5
    t.decimal  "BSD",                   precision: 20, scale: 5
    t.decimal  "BTC",                   precision: 20, scale: 5
    t.decimal  "BTN",                   precision: 20, scale: 5
    t.decimal  "BWP",                   precision: 20, scale: 5
    t.decimal  "BYN",                   precision: 20, scale: 5
    t.decimal  "BYR",                   precision: 20, scale: 5
    t.decimal  "BZD",                   precision: 20, scale: 5
    t.decimal  "CDF",                   precision: 20, scale: 5
    t.decimal  "CLF",                   precision: 20, scale: 5
    t.decimal  "CLP",                   precision: 20, scale: 5
    t.decimal  "COP",                   precision: 20, scale: 5
    t.decimal  "CRC",                   precision: 20, scale: 5
    t.decimal  "CUC",                   precision: 20, scale: 5
    t.decimal  "CUP",                   precision: 20, scale: 5
    t.decimal  "CVE",                   precision: 20, scale: 5
    t.decimal  "DJF",                   precision: 20, scale: 5
    t.decimal  "DOP",                   precision: 20, scale: 5
    t.decimal  "DZD",                   precision: 20, scale: 5
    t.decimal  "EEK",                   precision: 20, scale: 5
    t.decimal  "EGP",                   precision: 20, scale: 5
    t.decimal  "ERN",                   precision: 20, scale: 5
    t.decimal  "ETB",                   precision: 20, scale: 5
    t.decimal  "FJD",                   precision: 20, scale: 5
    t.decimal  "FKP",                   precision: 20, scale: 5
    t.decimal  "GEL",                   precision: 20, scale: 5
    t.decimal  "GGP",                   precision: 20, scale: 5
    t.decimal  "GHS",                   precision: 20, scale: 5
    t.decimal  "GIP",                   precision: 20, scale: 5
    t.decimal  "GMD",                   precision: 20, scale: 5
    t.decimal  "GNF",                   precision: 20, scale: 5
    t.decimal  "GTQ",                   precision: 20, scale: 5
    t.decimal  "GYD",                   precision: 20, scale: 5
    t.decimal  "HNL",                   precision: 20, scale: 5
    t.decimal  "HTG",                   precision: 20, scale: 5
    t.decimal  "IMP",                   precision: 20, scale: 5
    t.decimal  "IQD",                   precision: 20, scale: 5
    t.decimal  "IRR",                   precision: 20, scale: 5
    t.decimal  "ISK",                   precision: 20, scale: 5
    t.decimal  "JEP",                   precision: 20, scale: 5
    t.decimal  "JMD",                   precision: 20, scale: 5
    t.decimal  "JOD",                   precision: 20, scale: 5
    t.decimal  "KES",                   precision: 20, scale: 5
    t.decimal  "KGS",                   precision: 20, scale: 5
    t.decimal  "KHR",                   precision: 20, scale: 5
    t.decimal  "KMF",                   precision: 20, scale: 5
    t.decimal  "KPW",                   precision: 20, scale: 5
    t.decimal  "KWD",                   precision: 20, scale: 5
    t.decimal  "KYD",                   precision: 20, scale: 5
    t.decimal  "KZT",                   precision: 20, scale: 5
    t.decimal  "LAK",                   precision: 20, scale: 5
    t.decimal  "LBP",                   precision: 20, scale: 5
    t.decimal  "LKR",                   precision: 20, scale: 5
    t.decimal  "LRD",                   precision: 20, scale: 5
    t.decimal  "LSL",                   precision: 20, scale: 5
    t.decimal  "LTL",                   precision: 20, scale: 5
    t.decimal  "LVL",                   precision: 20, scale: 5
    t.decimal  "LYD",                   precision: 20, scale: 5
    t.decimal  "MAD",                   precision: 20, scale: 5
    t.decimal  "MDL",                   precision: 20, scale: 5
    t.decimal  "MGA",                   precision: 20, scale: 5
    t.decimal  "MKD",                   precision: 20, scale: 5
    t.decimal  "MMK",                   precision: 20, scale: 5
    t.decimal  "MNT",                   precision: 20, scale: 5
    t.decimal  "MOP",                   precision: 20, scale: 5
    t.decimal  "MRO",                   precision: 20, scale: 5
    t.decimal  "MUR",                   precision: 20, scale: 5
    t.decimal  "MVR",                   precision: 20, scale: 5
    t.decimal  "MWK",                   precision: 20, scale: 5
    t.decimal  "MZN",                   precision: 20, scale: 5
    t.decimal  "NAD",                   precision: 20, scale: 5
    t.decimal  "NGN",                   precision: 20, scale: 5
    t.decimal  "NIO",                   precision: 20, scale: 5
    t.decimal  "NPR",                   precision: 20, scale: 5
    t.decimal  "OMR",                   precision: 20, scale: 5
    t.decimal  "PAB",                   precision: 20, scale: 5
    t.decimal  "PEN",                   precision: 20, scale: 5
    t.decimal  "PGK",                   precision: 20, scale: 5
    t.decimal  "PKR",                   precision: 20, scale: 5
    t.decimal  "PYG",                   precision: 20, scale: 5
    t.decimal  "QAR",                   precision: 20, scale: 5
    t.decimal  "RSD",                   precision: 20, scale: 5
    t.decimal  "RWF",                   precision: 20, scale: 5
    t.decimal  "SAR",                   precision: 20, scale: 5
    t.decimal  "SBD",                   precision: 20, scale: 5
    t.decimal  "SCR",                   precision: 20, scale: 5
    t.decimal  "SDG",                   precision: 20, scale: 5
    t.decimal  "SHP",                   precision: 20, scale: 5
    t.decimal  "SLL",                   precision: 20, scale: 5
    t.decimal  "SOS",                   precision: 20, scale: 5
    t.decimal  "SRD",                   precision: 20, scale: 5
    t.decimal  "STD",                   precision: 20, scale: 5
    t.decimal  "SVC",                   precision: 20, scale: 5
    t.decimal  "SYP",                   precision: 20, scale: 5
    t.decimal  "SZL",                   precision: 20, scale: 5
    t.decimal  "TJS",                   precision: 20, scale: 5
    t.decimal  "TMT",                   precision: 20, scale: 5
    t.decimal  "TND",                   precision: 20, scale: 5
    t.decimal  "TOP",                   precision: 20, scale: 5
    t.decimal  "TTD",                   precision: 20, scale: 5
    t.decimal  "TWD",                   precision: 20, scale: 5
    t.decimal  "TZS",                   precision: 20, scale: 5
    t.decimal  "UAH",                   precision: 20, scale: 5
    t.decimal  "UGX",                   precision: 20, scale: 5
    t.decimal  "UYU",                   precision: 20, scale: 5
    t.decimal  "UZS",                   precision: 20, scale: 5
    t.decimal  "VEF",                   precision: 20, scale: 5
    t.decimal  "VND",                   precision: 20, scale: 5
    t.decimal  "VUV",                   precision: 20, scale: 5
    t.decimal  "WST",                   precision: 20, scale: 5
    t.decimal  "XAF",                   precision: 20, scale: 5
    t.decimal  "XAG",                   precision: 20, scale: 5
    t.decimal  "XAU",                   precision: 20, scale: 5
    t.decimal  "XCD",                   precision: 20, scale: 5
    t.decimal  "XDR",                   precision: 20, scale: 5
    t.decimal  "XOF",                   precision: 20, scale: 5
    t.decimal  "XPF",                   precision: 20, scale: 5
    t.decimal  "YER",                   precision: 20, scale: 5
    t.decimal  "ZMK",                   precision: 20, scale: 5
    t.decimal  "ZMW",                   precision: 20, scale: 5
    t.decimal  "ZWL",                   precision: 20, scale: 5
    t.boolean  "is_deleted",                                      default: false
  end

  add_index "amounts", ["currency_id"], name: "index_amounts_on_currency_id", using: :btree

  create_table "authentications", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.string   "provider",         limit: 255
    t.string   "uid",              limit: 255
    t.string   "name",             limit: 255
    t.string   "email",            limit: 255
    t.string   "nickname",         limit: 255
    t.string   "first_name",       limit: 255
    t.string   "last_name",        limit: 255
    t.string   "location",         limit: 255
    t.string   "description",      limit: 255
    t.string   "image",            limit: 255
    t.string   "phone",            limit: 255
    t.string   "urls",             limit: 255
    t.string   "token",            limit: 255
    t.string   "secret",           limit: 255
    t.boolean  "expires"
    t.datetime "expires_at"
    t.datetime "refresh_token_at"
    t.text     "extra",            limit: 65535
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "authentications", ["user_id"], name: "index_authentications_on_user_id", using: :btree

  create_table "auto_reload_configs", force: :cascade do |t|
    t.integer  "minimum_balance_id", limit: 4
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.boolean  "enabled",                        default: false
    t.integer  "reloadable_id",      limit: 4
    t.string   "reloadable_type",    limit: 255
  end

  add_index "auto_reload_configs", ["reloadable_type", "reloadable_id"], name: "index_auto_reload_configs_on_reloadable_type_and_reloadable_id", using: :btree

  create_table "auto_submit_configs", force: :cascade do |t|
    t.boolean  "enabled",                              default: false, null: false
    t.boolean  "limit_to_card_expenses",               default: false, null: false
    t.integer  "period_id",              limit: 4,                     null: false
    t.text     "default_memo",           limit: 65535
    t.integer  "default_policy_id",      limit: 4
    t.integer  "submitable_id",          limit: 4,                     null: false
    t.string   "submitable_type",        limit: 255,                   null: false
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
  end

  add_index "auto_submit_configs", ["default_policy_id"], name: "index_auto_submit_configs_on_default_policy_id", using: :btree
  add_index "auto_submit_configs", ["period_id"], name: "index_auto_submit_configs_on_period_id", using: :btree
  add_index "auto_submit_configs", ["submitable_type", "submitable_id"], name: "index_auto_submit_configs_on_submitable_type_and_submitable_id", using: :btree

  create_table "auto_sync_config_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "auto_sync_configs", force: :cascade do |t|
    t.integer  "company_id",               limit: 4
    t.integer  "auto_sync_config_type_id", limit: 4
    t.boolean  "categories_sync",                    default: false
    t.boolean  "company_tags_sync",                  default: false
    t.boolean  "external_users_sync",                default: false
    t.boolean  "reports_sync",                       default: false
    t.integer  "period_id",                limit: 4
    t.boolean  "enabled",                            default: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  add_index "auto_sync_configs", ["auto_sync_config_type_id"], name: "index_auto_sync_configs_on_auto_sync_config_type_id", using: :btree
  add_index "auto_sync_configs", ["company_id"], name: "index_auto_sync_configs_on_company_id", using: :btree
  add_index "auto_sync_configs", ["period_id"], name: "index_auto_sync_configs_on_period_id", using: :btree

  create_table "balance_sheets", force: :cascade do |t|
    t.integer  "user_id",                   limit: 4
    t.integer  "cash_in_hand_id",           limit: 4
    t.integer  "approved_reports_total_id", limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "pending_advance_id",        limit: 4
  end

  add_index "balance_sheets", ["approved_reports_total_id"], name: "index_balance_sheets_on_approved_reports_total_id", using: :btree
  add_index "balance_sheets", ["cash_in_hand_id"], name: "index_balance_sheets_on_cash_in_hand_id", using: :btree
  add_index "balance_sheets", ["user_id"], name: "index_balance_sheets_on_user_id", using: :btree

  create_table "bank_accounts", force: :cascade do |t|
    t.integer  "yes_bank_vendor_id", limit: 4
    t.string   "account_number",     limit: 255
    t.string   "ifsc",               limit: 255
    t.string   "name",               limit: 255
    t.string   "address_1",          limit: 255
    t.string   "address_2",          limit: 255
    t.string   "address_3",          limit: 255
    t.string   "pin_code",           limit: 255
    t.string   "country",            limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "account_owner_id",   limit: 4
    t.string   "account_owner_type", limit: 255
  end

  add_index "bank_accounts", ["yes_bank_vendor_id"], name: "index_bank_accounts_on_yes_bank_vendor_id", using: :btree

  create_table "bank_transactions", force: :cascade do |t|
    t.string   "unique_request_number",       limit: 255
    t.string   "transfer_type",               limit: 255
    t.string   "bank_reference_number",       limit: 255
    t.string   "unique_response_number",      limit: 255
    t.integer  "amount_id",                   limit: 4
    t.integer  "beneficiary_bank_account_id", limit: 4
    t.integer  "company_id",                  limit: 4
    t.integer  "transfer_status_id",          limit: 4
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "bank_response",               limit: 255
    t.boolean  "refunded"
  end

  add_index "bank_transactions", ["amount_id"], name: "index_bank_transactions_on_amount_id", using: :btree
  add_index "bank_transactions", ["beneficiary_bank_account_id"], name: "index_bank_transactions_on_beneficiary_bank_account_id", using: :btree
  add_index "bank_transactions", ["company_id"], name: "index_bank_transactions_on_company_id", using: :btree
  add_index "bank_transactions", ["transfer_status_id"], name: "index_bank_transactions_on_transfer_status_id", using: :btree

  create_table "bank_transfer_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "budget_rules", force: :cascade do |t|
    t.integer  "category_id",          limit: 4
    t.integer  "amount_id",            limit: 4
    t.integer  "period_id",            limit: 4
    t.integer  "policy_id",            limit: 4
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "rule_type_id",         limit: 4
    t.boolean  "include_reimbursable",           default: true
  end

  add_index "budget_rules", ["amount_id"], name: "index_budget_rules_on_amount_id", using: :btree
  add_index "budget_rules", ["category_id"], name: "index_budget_rules_on_category_id", using: :btree
  add_index "budget_rules", ["period_id"], name: "index_budget_rules_on_period_id", using: :btree
  add_index "budget_rules", ["policy_id"], name: "index_budget_rules_on_policy_id", using: :btree
  add_index "budget_rules", ["rule_type_id"], name: "index_budget_rules_on_rule_type_id", using: :btree

  create_table "card_assign_request_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "card_assign_request_track_actions", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "card_assign_request_tracks", force: :cascade do |t|
    t.integer  "card_assign_request_id", limit: 4,     null: false
    t.integer  "action_resource_id",     limit: 4
    t.string   "action_resource_type",   limit: 255
    t.integer  "action_id",              limit: 4,     null: false
    t.text     "note",                   limit: 65535
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "card_assign_request_tracks", ["action_id"], name: "index_card_assign_request_tracks_on_action_id", using: :btree
  add_index "card_assign_request_tracks", ["action_resource_id"], name: "index_card_assign_request_tracks_on_action_resource_id", using: :btree
  add_index "card_assign_request_tracks", ["action_resource_type"], name: "index_card_assign_request_tracks_on_action_resource_type", using: :btree
  add_index "card_assign_request_tracks", ["card_assign_request_id"], name: "index_card_assign_request_tracks_on_card_assign_request_id", using: :btree

  create_table "card_assign_requests", force: :cascade do |t|
    t.integer  "card_id",                   limit: 4
    t.integer  "card_owner_id",             limit: 4,                 null: false
    t.integer  "initiating_resource_id",    limit: 4,                 null: false
    t.string   "initiating_resource_type",  limit: 255,               null: false
    t.integer  "status_id",                 limit: 4,                 null: false
    t.integer  "assigned_by_resource_id",   limit: 4
    t.string   "assigned_by_resource_type", limit: 255
    t.datetime "assigned_on"
    t.integer  "card_program_id",           limit: 4,                 null: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "admin_review_workflow_id",  limit: 4
    t.integer  "review_position",           limit: 4,     default: 0
    t.text     "admin_note",                limit: 65535
    t.integer  "company_id",                limit: 4,                 null: false
  end

  add_index "card_assign_requests", ["admin_review_workflow_id"], name: "index_card_assign_requests_on_admin_review_workflow_id", using: :btree
  add_index "card_assign_requests", ["assigned_by_resource_id"], name: "index_card_assign_requests_on_assigned_by_resource_id", using: :btree
  add_index "card_assign_requests", ["assigned_by_resource_type"], name: "index_card_assign_requests_on_assigned_by_resource_type", using: :btree
  add_index "card_assign_requests", ["card_id"], name: "index_card_assign_requests_on_card_id", using: :btree
  add_index "card_assign_requests", ["card_owner_id"], name: "index_card_assign_requests_on_card_owner_id", using: :btree
  add_index "card_assign_requests", ["card_program_id"], name: "index_card_assign_requests_on_card_program_id", using: :btree
  add_index "card_assign_requests", ["company_id"], name: "index_card_assign_requests_on_company_id", using: :btree
  add_index "card_assign_requests", ["initiating_resource_id"], name: "index_card_assign_requests_on_initiating_resource_id", using: :btree
  add_index "card_assign_requests", ["initiating_resource_type"], name: "index_card_assign_requests_on_initiating_resource_type", using: :btree
  add_index "card_assign_requests", ["status_id"], name: "index_card_assign_requests_on_status_id", using: :btree

  create_table "card_balance_histories", force: :cascade do |t|
    t.integer  "card_id",    limit: 4
    t.integer  "amount_id",  limit: 4
    t.datetime "timestamp"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "card_balance_histories", ["amount_id"], name: "index_card_balance_histories_on_amount_id", using: :btree
  add_index "card_balance_histories", ["card_id"], name: "index_card_balance_histories_on_card_id", using: :btree

  create_table "card_configurations", force: :cascade do |t|
    t.integer  "prepaid_card_id",       limit: 4
    t.integer  "configured_by_user_id", limit: 4
    t.integer  "card_status_id",        limit: 4
    t.datetime "end_date"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "card_configurations", ["card_status_id"], name: "index_card_configurations_on_card_status_id", using: :btree
  add_index "card_configurations", ["configured_by_user_id"], name: "index_card_configurations_on_configured_by_user_id", using: :btree
  add_index "card_configurations", ["prepaid_card_id"], name: "index_card_configurations_on_prepaid_card_id", using: :btree

  create_table "card_expenses", force: :cascade do |t|
    t.text     "editable_merchant",   limit: 65535
    t.integer  "card_transaction_id", limit: 4
    t.integer  "expense_id",          limit: 4
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "surcharge_id",        limit: 4
    t.boolean  "is_deleted",                        default: false
    t.boolean  "cancelled",                         default: false
    t.boolean  "atm_surcharge",                     default: false
  end

  add_index "card_expenses", ["card_transaction_id"], name: "index_card_expenses_on_card_transaction_id", using: :btree
  add_index "card_expenses", ["expense_id"], name: "index_card_expenses_on_expense_id", using: :btree

  create_table "card_fund_transactions", force: :cascade do |t|
    t.string   "transaction_id",  limit: 255,   null: false
    t.text     "response",        limit: 65535, null: false
    t.string   "action",          limit: 255,   null: false
    t.integer  "requesting_user", limit: 4,     null: false
    t.integer  "for_user",        limit: 4,     null: false
    t.text     "post_params",     limit: 65535, null: false
    t.text     "post_url",        limit: 65535, null: false
    t.string   "amount_value",    limit: 255,   null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "card_fund_transactions", ["for_user"], name: "index_card_fund_transactions_on_for_user", using: :btree
  add_index "card_fund_transactions", ["requesting_user"], name: "index_card_fund_transactions_on_requesting_user", using: :btree

  create_table "card_limits", force: :cascade do |t|
    t.integer  "card_restriction_id", limit: 4
    t.integer  "transactions",        limit: 4
    t.integer  "period_id",           limit: 4
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.decimal  "budget",                        precision: 10
    t.integer  "limit_type_id",       limit: 4
    t.boolean  "allowed"
  end

  add_index "card_limits", ["card_restriction_id"], name: "index_card_limits_on_card_restriction_id", using: :btree
  add_index "card_limits", ["period_id"], name: "index_card_limits_on_period_id", using: :btree

  create_table "card_programs", force: :cascade do |t|
    t.string   "name",                          limit: 255
    t.boolean  "create_expense"
    t.boolean  "receive_reimbursement"
    t.boolean  "personal_wallet_fund_transfer"
    t.boolean  "spend_restrictions"
    t.boolean  "end_date_restrictions"
    t.boolean  "manager_credit"
    t.boolean  "manager_debit"
    t.boolean  "manager_blockable"
    t.boolean  "manager_view_balance"
    t.boolean  "manager_view_eligibility"
    t.boolean  "manager_view_transactions"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.boolean  "non_personal_fund_transfer"
  end

  create_table "card_request_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "card_restrictions", force: :cascade do |t|
    t.integer  "card_id",              limit: 4
    t.boolean  "channel_atm"
    t.boolean  "channel_pos"
    t.boolean  "channel_online"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.boolean  "channel_ecom_pos"
    t.integer  "mcc_group_id",         limit: 4
    t.string   "mcc_restriction_type", limit: 255
  end

  add_index "card_restrictions", ["card_id"], name: "index_card_restrictions_on_card_id", using: :btree

  create_table "card_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "card_transactions", force: :cascade do |t|
    t.integer  "user_id",                      limit: 4
    t.integer  "card_id",                      limit: 4
    t.string   "merchant_name",                limit: 255
    t.string   "transaction_type",             limit: 255
    t.text     "post_data",                    limit: 65535
    t.integer  "transaction_amount_id",        limit: 4
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.string   "reference_id",                 limit: 255
    t.string   "auth_transaction_id",          limit: 255
    t.string   "transaction_mode",             limit: 255
    t.string   "itzcash_merchant_key",         limit: 255
    t.string   "merchant_city",                limit: 255
    t.string   "response_code",                limit: 255
    t.string   "serial_id",                    limit: 255
    t.string   "product_code",                 limit: 255
    t.datetime "transaction_timestamp"
    t.boolean  "expensed",                                   default: false
    t.text     "error_message",                limit: 65535
    t.integer  "billing_amount_id",            limit: 4
    t.boolean  "is_deleted",                                 default: false
    t.string   "mcc_code",                     limit: 255
    t.string   "transaction_status",           limit: 255
    t.string   "api_reference_id",             limit: 255
    t.boolean  "cancelled",                                  default: false
    t.integer  "cancelled_against_expense_id", limit: 4
    t.string   "type_of_details",              limit: 255
    t.boolean  "success"
    t.string   "acquirer_id",                  limit: 255
    t.string   "mid",                          limit: 255
    t.string   "tid",                          limit: 255
    t.text     "transaction_message",          limit: 65535
  end

  add_index "card_transactions", ["card_id"], name: "index_card_transactions_on_card_id", using: :btree
  add_index "card_transactions", ["transaction_amount_id"], name: "index_card_transactions_on_transaction_amount_id", using: :btree
  add_index "card_transactions", ["user_id"], name: "index_card_transactions_on_user_id", using: :btree

  create_table "card_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "cards", force: :cascade do |t|
    t.integer  "user_id",                  limit: 4
    t.string   "ending_number",            limit: 255,                   null: false
    t.string   "proxy",                    limit: 255,                   null: false
    t.integer  "card_type_id",             limit: 4
    t.text     "description",              limit: 65535
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.integer  "company_id",               limit: 4,                     null: false
    t.integer  "disabled_by_role_id",      limit: 4
    t.integer  "disabled_by_user_id",      limit: 4
    t.boolean  "active"
    t.text     "disable_note",             limit: 65535
    t.integer  "card_balance_id",          limit: 4
    t.integer  "card_program_id",          limit: 4
    t.integer  "card_eligibility_id",      limit: 4
    t.boolean  "admin_unblockable",                      default: true
    t.integer  "itz_cash_card_program_id", limit: 4
    t.integer  "card_status_id",           limit: 4,                     null: false
    t.boolean  "is_deleted",                             default: false
    t.boolean  "hotlisted",                              default: false
  end

  add_index "cards", ["card_type_id"], name: "index_cards_on_card_type_id", using: :btree
  add_index "cards", ["company_id"], name: "index_cards_on_company_id", using: :btree
  add_index "cards", ["user_id"], name: "index_cards_on_user_id", using: :btree

  create_table "cash_on_hands", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "balance_id", limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "cash_on_hands", ["balance_id"], name: "index_cash_on_hands_on_balance_id", using: :btree
  add_index "cash_on_hands", ["user_id"], name: "index_cash_on_hands_on_user_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.integer  "company_id",   limit: 4,                  null: false
    t.string   "name",         limit: 255,                null: false
    t.string   "gl_code",      limit: 255
    t.string   "payroll_code", limit: 255
    t.boolean  "active",                   default: true, null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "categories", ["company_id"], name: "index_categories_on_company_id", using: :btree

  create_table "channel_types", force: :cascade do |t|
    t.string "name",         limit: 255
    t.string "abbreviation", limit: 255
  end

  create_table "city_id_city_code_mappings", force: :cascade do |t|
    t.string   "city_id",    limit: 255
    t.string   "city_code",  limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "companies", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "active",                       default: true, null: false
    t.integer  "base_currency_id", limit: 4,   default: 1
  end

  create_table "company_account_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "company_accounts", force: :cascade do |t|
    t.integer  "company_id",              limit: 4, null: false
    t.integer  "wallet_balance_id",       limit: 4
    t.integer  "company",                 limit: 4
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "company_account_type_id", limit: 4
  end

  add_index "company_accounts", ["company"], name: "index_company_accounts_on_company", using: :btree
  add_index "company_accounts", ["company_account_type_id"], name: "index_company_accounts_on_company_account_type_id", using: :btree
  add_index "company_accounts", ["company_id"], name: "index_company_accounts_on_company_id", using: :btree
  add_index "company_accounts", ["wallet_balance_id"], name: "index_company_accounts_on_wallet_balance_id", using: :btree

  create_table "company_agreement_tracks", force: :cascade do |t|
    t.integer  "user_id",      limit: 4,   null: false
    t.integer  "agreement_id", limit: 4,   null: false
    t.string   "ip_address",   limit: 255
    t.string   "referrer",     limit: 255
    t.string   "application",  limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "company_id",   limit: 4
  end

  add_index "company_agreement_tracks", ["agreement_id"], name: "index_company_agreement_tracks_on_agreement_id", using: :btree
  add_index "company_agreement_tracks", ["user_id"], name: "index_company_agreement_tracks_on_user_id", using: :btree

  create_table "company_balance_histories", force: :cascade do |t|
    t.integer  "company_id",                              limit: 4
    t.integer  "neft_transfer_id",                        limit: 4
    t.integer  "company_balance_id",                      limit: 4
    t.integer  "company_withdrawal_to_card_id",           limit: 4
    t.integer  "company_load_from_card_id",               limit: 4
    t.integer  "card_load_from_wallet_id",                limit: 4
    t.integer  "card_withdrawal_to_wallet_id",            limit: 4
    t.integer  "card_balance_id",                         limit: 4
    t.integer  "card_expenses_id",                        limit: 4
    t.integer  "wallet_load_from_wallet_id",              limit: 4
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "card_atm_withdrawal_id",                  limit: 4
    t.integer  "company_withdrawal_to_wallet_id",         limit: 4
    t.integer  "company_load_from_wallet_id",             limit: 4
    t.integer  "card_withdrawal_to_card_id",              limit: 4
    t.integer  "card_withdrawal_to_virtual_account_id",   limit: 4
    t.integer  "card_load_from_card_id",                  limit: 4
    t.integer  "card_load_from_virtual_account_id",       limit: 4
    t.integer  "wallet_withdrawal_to_wallet_id",          limit: 4
    t.integer  "wallet_withdrawal_to_card_id",            limit: 4
    t.integer  "wallet_withdrawal_to_virtual_account_id", limit: 4
    t.integer  "wallet_load_from_card_id",                limit: 4
    t.integer  "wallet_load_from_virtual_account_id",     limit: 4
    t.date     "date"
    t.integer  "wallet_balance_id",                       limit: 4
    t.integer  "cash_on_hand_load_id",                    limit: 4
    t.integer  "cash_on_hand_withdrawal_id",              limit: 4
    t.integer  "cash_on_hand_balance_id",                 limit: 4
  end

  add_index "company_balance_histories", ["card_balance_id"], name: "index_company_balance_histories_on_card_balance_id", using: :btree
  add_index "company_balance_histories", ["card_expenses_id"], name: "index_company_balance_histories_on_card_expenses_id", using: :btree
  add_index "company_balance_histories", ["card_load_from_wallet_id"], name: "index_company_balance_histories_on_card_load_from_wallet_id", using: :btree
  add_index "company_balance_histories", ["card_withdrawal_to_wallet_id"], name: "index_company_balance_histories_on_card_withdrawal_to_wallet_id", using: :btree
  add_index "company_balance_histories", ["company_balance_id"], name: "index_company_balance_histories_on_company_balance_id", using: :btree
  add_index "company_balance_histories", ["company_id"], name: "index_company_balance_histories_on_company_id", using: :btree
  add_index "company_balance_histories", ["company_load_from_card_id"], name: "index_company_balance_histories_on_company_load_from_card_id", using: :btree
  add_index "company_balance_histories", ["company_withdrawal_to_card_id"], name: "index_company_balance_histories_on_company_withdrawal_to_card_id", using: :btree
  add_index "company_balance_histories", ["neft_transfer_id"], name: "index_company_balance_histories_on_neft_transfer_id", using: :btree
  add_index "company_balance_histories", ["wallet_load_from_virtual_account_id"], name: "index_wal_load_on_company_history", using: :btree
  add_index "company_balance_histories", ["wallet_load_from_wallet_id"], name: "index_company_balance_histories_on_wallet_load_from_wallet_id", using: :btree
  add_index "company_balance_histories", ["wallet_withdrawal_to_card_id"], name: "index_wal_2_card_on_company_history", using: :btree
  add_index "company_balance_histories", ["wallet_withdrawal_to_virtual_account_id"], name: "index_wal_2_va_on_company_history", using: :btree
  add_index "company_balance_histories", ["wallet_withdrawal_to_wallet_id"], name: "index_wal_2_wal_on_company_history", using: :btree

  create_table "company_configurations", force: :cascade do |t|
    t.integer  "company_id",                  limit: 4,                     null: false
    t.integer  "contact_id",                  limit: 4
    t.boolean  "verified",                                  default: false
    t.string   "logo_file_name",              limit: 255
    t.string   "logo_content_type",           limit: 255
    t.integer  "logo_file_size",              limit: 4
    t.datetime "logo_updated_at"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.boolean  "other_expense_types",                       default: false
    t.text     "encrypted_easy_login_params", limit: 65535
    t.string   "registered_mobile_number",    limit: 255
  end

  add_index "company_configurations", ["company_id"], name: "index_company_configurations_on_company_id", using: :btree
  add_index "company_configurations", ["contact_id"], name: "index_company_configurations_on_contact_id", using: :btree

  create_table "company_funds_load_request_types", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "company_funds_load_requests", force: :cascade do |t|
    t.integer  "company_id",           limit: 4
    t.integer  "requested_by_user_id", limit: 4,                    null: false
    t.string   "reference_id",         limit: 255,                  null: false
    t.date     "date",                                              null: false
    t.integer  "amount_id",            limit: 4
    t.text     "remark",               limit: 65535
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "bank_type_id",         limit: 4
    t.boolean  "is_active",                          default: true
  end

  add_index "company_funds_load_requests", ["amount_id"], name: "index_company_funds_load_requests_on_amount_id", using: :btree
  add_index "company_funds_load_requests", ["bank_type_id"], name: "index_company_funds_load_requests_on_bank_type_id", using: :btree
  add_index "company_funds_load_requests", ["company_id"], name: "index_company_funds_load_requests_on_company_id", using: :btree
  add_index "company_funds_load_requests", ["requested_by_user_id"], name: "index_company_funds_load_requests_on_requested_by_user_id", using: :btree

  create_table "company_kyc_document_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "identifier", limit: 255
  end

  create_table "company_kyc_trail_actions", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "company_kyc_trails", force: :cascade do |t|
    t.integer  "company_kyc_id",       limit: 4
    t.integer  "action_resource_id",   limit: 4
    t.string   "action_resource_type", limit: 255
    t.integer  "action_id",            limit: 4
    t.text     "note",                 limit: 65535
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "company_kyc_trails", ["company_kyc_id"], name: "index_company_kyc_trails_on_company_kyc_id", using: :btree

  create_table "company_kycs", force: :cascade do |t|
    t.string   "pan_card_file_name",                        limit: 255
    t.string   "pan_card_content_type",                     limit: 255
    t.integer  "pan_card_file_size",                        limit: 4
    t.datetime "pan_card_updated_at"
    t.string   "coi_file_name",                             limit: 255
    t.string   "coi_content_type",                          limit: 255
    t.integer  "coi_file_size",                             limit: 4
    t.datetime "coi_updated_at"
    t.string   "board_resolution_file_name",                limit: 255
    t.string   "board_resolution_content_type",             limit: 255
    t.integer  "board_resolution_file_size",                limit: 4
    t.datetime "board_resolution_updated_at"
    t.integer  "kyc_status_id",                             limit: 4
    t.integer  "company_id",                                limit: 4,                     null: false
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
    t.date     "date_of_establishment"
    t.text     "street_2",                                  limit: 65535
    t.text     "street_3",                                  limit: 65535
    t.string   "registered_mobile_number",                  limit: 255
    t.string   "pan_card_no",                               limit: 255
    t.string   "pin_code",                                  limit: 255
    t.string   "city_code",                                 limit: 255
    t.string   "aadhar_card_file_name",                     limit: 255
    t.string   "aadhar_card_content_type",                  limit: 255
    t.integer  "aadhar_card_file_size",                     limit: 4
    t.datetime "aadhar_card_updated_at"
    t.string   "vat_registration_certificate_file_name",    limit: 255
    t.string   "vat_registration_certificate_content_type", limit: 255
    t.integer  "vat_registration_certificate_file_size",    limit: 4
    t.datetime "vat_registration_certificate_updated_at"
    t.string   "registration_of_trust_file_name",           limit: 255
    t.string   "registration_of_trust_content_type",        limit: 255
    t.integer  "registration_of_trust_file_size",           limit: 4
    t.datetime "registration_of_trust_updated_at"
    t.string   "driving_licence_file_name",                 limit: 255
    t.string   "driving_licence_content_type",              limit: 255
    t.integer  "driving_licence_file_size",                 limit: 4
    t.datetime "driving_licence_updated_at"
    t.string   "passport_file_name",                        limit: 255
    t.string   "passport_content_type",                     limit: 255
    t.integer  "passport_file_size",                        limit: 4
    t.datetime "passport_updated_at"
    t.integer  "company_type_id",                           limit: 4
    t.string   "certificate_of_registration_file_name",     limit: 255
    t.string   "certificate_of_registration_content_type",  limit: 255
    t.integer  "certificate_of_registration_file_size",     limit: 4
    t.datetime "certificate_of_registration_updated_at"
    t.integer  "customer_type_id",                          limit: 4
    t.boolean  "user_confirmed",                                          default: false
  end

  add_index "company_kycs", ["company_id"], name: "index_company_kycs_on_company_id", using: :btree

  create_table "company_tags", force: :cascade do |t|
    t.integer  "company_id", limit: 4,                  null: false
    t.string   "name",       limit: 255,                null: false
    t.string   "gl_code",    limit: 255
    t.boolean  "active",                 default: true, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "company_tags", ["company_id"], name: "index_company_tags_on_company_id", using: :btree

  create_table "company_transactions", force: :cascade do |t|
    t.integer  "company_id",            limit: 4,   null: false
    t.string   "request_id",            limit: 255, null: false
    t.string   "merchant_name",         limit: 255, null: false
    t.datetime "transaction_date",                  null: false
    t.integer  "transaction_amount_id", limit: 4,   null: false
    t.string   "transaction_type",      limit: 255, null: false
    t.string   "transaction_id",        limit: 255, null: false
    t.integer  "balance_amount_id",     limit: 4,   null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "transaction_mode",      limit: 255
    t.string   "merchant_type_key",     limit: 255
  end

  add_index "company_transactions", ["balance_amount_id"], name: "index_company_transactions_on_balance_amount_id", using: :btree
  add_index "company_transactions", ["company_id"], name: "index_company_transactions_on_company_id", using: :btree
  add_index "company_transactions", ["transaction_amount_id"], name: "index_company_transactions_on_transaction_amount_id", using: :btree

  create_table "company_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "contacts", force: :cascade do |t|
    t.string   "email",            limit: 255
    t.string   "name",             limit: 255
    t.string   "number",           limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "contactable_id",   limit: 4
    t.string   "contactable_type", limit: 255
    t.string   "designation",      limit: 255
  end

  create_table "crono_jobs", force: :cascade do |t|
    t.string   "job_id",            limit: 255,      null: false
    t.text     "log",               limit: 16777215
    t.datetime "last_performed_at"
    t.boolean  "healthy"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "crono_jobs", ["job_id"], name: "index_crono_jobs_on_job_id", unique: true, using: :btree

  create_table "currencies", force: :cascade do |t|
    t.string   "country",      limit: 255
    t.string   "country_code", limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "symbol",       limit: 255
  end

  create_table "currency_conversion_rates", force: :cascade do |t|
    t.date     "date",                                null: false
    t.decimal  "INR",        precision: 10, scale: 5
    t.decimal  "USD",        precision: 10, scale: 5
    t.decimal  "GBP",        precision: 10, scale: 5
    t.decimal  "EUR",        precision: 10, scale: 5
    t.decimal  "CAD",        precision: 10, scale: 5
    t.decimal  "HRK",        precision: 10, scale: 5
    t.decimal  "RUB",        precision: 10, scale: 5
    t.decimal  "BGN",        precision: 10, scale: 5
    t.decimal  "BRL",        precision: 10, scale: 5
    t.decimal  "CHF",        precision: 10, scale: 5
    t.decimal  "CNY",        precision: 10, scale: 5
    t.decimal  "CZK",        precision: 10, scale: 5
    t.decimal  "DKK",        precision: 10, scale: 5
    t.decimal  "HKD",        precision: 10, scale: 5
    t.decimal  "HUF",        precision: 10, scale: 5
    t.decimal  "IDR",        precision: 10, scale: 5
    t.decimal  "ILS",        precision: 10, scale: 5
    t.decimal  "JPY",        precision: 10, scale: 5
    t.decimal  "KRW",        precision: 10, scale: 5
    t.decimal  "MXN",        precision: 10, scale: 5
    t.decimal  "MYR",        precision: 10, scale: 5
    t.decimal  "NOK",        precision: 10, scale: 5
    t.decimal  "NZD",        precision: 10, scale: 5
    t.decimal  "PHP",        precision: 10, scale: 5
    t.decimal  "PLN",        precision: 10, scale: 5
    t.decimal  "RON",        precision: 10, scale: 5
    t.decimal  "SEK",        precision: 10, scale: 5
    t.decimal  "SGD",        precision: 10, scale: 5
    t.decimal  "THB",        precision: 10, scale: 5
    t.decimal  "TRY",        precision: 10, scale: 5
    t.decimal  "ZAR",        precision: 10, scale: 5
    t.decimal  "AUD",        precision: 10, scale: 5
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.decimal  "AED",        precision: 10, scale: 5
    t.decimal  "AFN",        precision: 10, scale: 5
    t.decimal  "ALL",        precision: 10, scale: 5
    t.decimal  "AMD",        precision: 10, scale: 5
    t.decimal  "ANG",        precision: 10, scale: 5
    t.decimal  "AOA",        precision: 10, scale: 5
    t.decimal  "ARS",        precision: 10, scale: 5
    t.decimal  "AWG",        precision: 10, scale: 5
    t.decimal  "AZN",        precision: 10, scale: 5
    t.decimal  "BAM",        precision: 10, scale: 5
    t.decimal  "BBD",        precision: 10, scale: 5
    t.decimal  "BDT",        precision: 10, scale: 5
    t.decimal  "BHD",        precision: 10, scale: 5
    t.decimal  "BIF",        precision: 10, scale: 5
    t.decimal  "BMD",        precision: 10, scale: 5
    t.decimal  "BND",        precision: 10, scale: 5
    t.decimal  "BOB",        precision: 10, scale: 5
    t.decimal  "BSD",        precision: 10, scale: 5
    t.decimal  "BTC",        precision: 10, scale: 5
    t.decimal  "BTN",        precision: 10, scale: 5
    t.decimal  "BWP",        precision: 10, scale: 5
    t.decimal  "BYN",        precision: 10, scale: 5
    t.decimal  "BYR",        precision: 10, scale: 5
    t.decimal  "BZD",        precision: 10, scale: 5
    t.decimal  "CDF",        precision: 10, scale: 5
    t.decimal  "CLF",        precision: 10, scale: 5
    t.decimal  "CLP",        precision: 10, scale: 5
    t.decimal  "COP",        precision: 10, scale: 5
    t.decimal  "CRC",        precision: 10, scale: 5
    t.decimal  "CUC",        precision: 10, scale: 5
    t.decimal  "CUP",        precision: 10, scale: 5
    t.decimal  "CVE",        precision: 10, scale: 5
    t.decimal  "DJF",        precision: 10, scale: 5
    t.decimal  "DOP",        precision: 10, scale: 5
    t.decimal  "DZD",        precision: 10, scale: 5
    t.decimal  "EEK",        precision: 10, scale: 5
    t.decimal  "EGP",        precision: 10, scale: 5
    t.decimal  "ERN",        precision: 10, scale: 5
    t.decimal  "ETB",        precision: 10, scale: 5
    t.decimal  "FJD",        precision: 10, scale: 5
    t.decimal  "FKP",        precision: 10, scale: 5
    t.decimal  "GEL",        precision: 10, scale: 5
    t.decimal  "GGP",        precision: 10, scale: 5
    t.decimal  "GHS",        precision: 10, scale: 5
    t.decimal  "GIP",        precision: 10, scale: 5
    t.decimal  "GMD",        precision: 10, scale: 5
    t.decimal  "GNF",        precision: 10, scale: 5
    t.decimal  "GTQ",        precision: 10, scale: 5
    t.decimal  "GYD",        precision: 10, scale: 5
    t.decimal  "HNL",        precision: 10, scale: 5
    t.decimal  "HTG",        precision: 10, scale: 5
    t.decimal  "IMP",        precision: 10, scale: 5
    t.decimal  "IQD",        precision: 10, scale: 5
    t.decimal  "IRR",        precision: 10, scale: 5
    t.decimal  "ISK",        precision: 10, scale: 5
    t.decimal  "JEP",        precision: 10, scale: 5
    t.decimal  "JMD",        precision: 10, scale: 5
    t.decimal  "JOD",        precision: 10, scale: 5
    t.decimal  "KES",        precision: 10, scale: 5
    t.decimal  "KGS",        precision: 10, scale: 5
    t.decimal  "KHR",        precision: 10, scale: 5
    t.decimal  "KMF",        precision: 10, scale: 5
    t.decimal  "KPW",        precision: 10, scale: 5
    t.decimal  "KWD",        precision: 10, scale: 5
    t.decimal  "KYD",        precision: 10, scale: 5
    t.decimal  "KZT",        precision: 10, scale: 5
    t.decimal  "LAK",        precision: 10, scale: 5
    t.decimal  "LBP",        precision: 10, scale: 5
    t.decimal  "LKR",        precision: 10, scale: 5
    t.decimal  "LRD",        precision: 10, scale: 5
    t.decimal  "LSL",        precision: 10, scale: 5
    t.decimal  "LTL",        precision: 10, scale: 5
    t.decimal  "LVL",        precision: 10, scale: 5
    t.decimal  "LYD",        precision: 10, scale: 5
    t.decimal  "MAD",        precision: 10, scale: 5
    t.decimal  "MDL",        precision: 10, scale: 5
    t.decimal  "MGA",        precision: 10, scale: 5
    t.decimal  "MKD",        precision: 10, scale: 5
    t.decimal  "MMK",        precision: 10, scale: 5
    t.decimal  "MNT",        precision: 10, scale: 5
    t.decimal  "MOP",        precision: 10, scale: 5
    t.decimal  "MRO",        precision: 10, scale: 5
    t.decimal  "MUR",        precision: 10, scale: 5
    t.decimal  "MVR",        precision: 10, scale: 5
    t.decimal  "MWK",        precision: 10, scale: 5
    t.decimal  "MZN",        precision: 10, scale: 5
    t.decimal  "NAD",        precision: 10, scale: 5
    t.decimal  "NGN",        precision: 10, scale: 5
    t.decimal  "NIO",        precision: 10, scale: 5
    t.decimal  "NPR",        precision: 10, scale: 5
    t.decimal  "OMR",        precision: 10, scale: 5
    t.decimal  "PAB",        precision: 10, scale: 5
    t.decimal  "PEN",        precision: 10, scale: 5
    t.decimal  "PGK",        precision: 10, scale: 5
    t.decimal  "PKR",        precision: 10, scale: 5
    t.decimal  "PYG",        precision: 10, scale: 5
    t.decimal  "QAR",        precision: 10, scale: 5
    t.decimal  "RSD",        precision: 10, scale: 5
    t.decimal  "RWF",        precision: 10, scale: 5
    t.decimal  "SAR",        precision: 10, scale: 5
    t.decimal  "SBD",        precision: 10, scale: 5
    t.decimal  "SCR",        precision: 10, scale: 5
    t.decimal  "SDG",        precision: 10, scale: 5
    t.decimal  "SHP",        precision: 10, scale: 5
    t.decimal  "SLL",        precision: 10, scale: 5
    t.decimal  "SOS",        precision: 10, scale: 5
    t.decimal  "SRD",        precision: 10, scale: 5
    t.decimal  "STD",        precision: 10, scale: 5
    t.decimal  "SVC",        precision: 10, scale: 5
    t.decimal  "SYP",        precision: 10, scale: 5
    t.decimal  "SZL",        precision: 10, scale: 5
    t.decimal  "TJS",        precision: 10, scale: 5
    t.decimal  "TMT",        precision: 10, scale: 5
    t.decimal  "TND",        precision: 10, scale: 5
    t.decimal  "TOP",        precision: 10, scale: 5
    t.decimal  "TTD",        precision: 10, scale: 5
    t.decimal  "TWD",        precision: 10, scale: 5
    t.decimal  "TZS",        precision: 10, scale: 5
    t.decimal  "UAH",        precision: 10, scale: 5
    t.decimal  "UGX",        precision: 10, scale: 5
    t.decimal  "UYU",        precision: 10, scale: 5
    t.decimal  "UZS",        precision: 10, scale: 5
    t.decimal  "VEF",        precision: 10, scale: 5
    t.decimal  "VND",        precision: 10, scale: 5
    t.decimal  "VUV",        precision: 10, scale: 5
    t.decimal  "WST",        precision: 10, scale: 5
    t.decimal  "XAF",        precision: 10, scale: 5
    t.decimal  "XAG",        precision: 10, scale: 5
    t.decimal  "XAU",        precision: 10, scale: 5
    t.decimal  "XCD",        precision: 10, scale: 5
    t.decimal  "XDR",        precision: 10, scale: 5
    t.decimal  "XOF",        precision: 10, scale: 5
    t.decimal  "XPF",        precision: 10, scale: 5
    t.decimal  "YER",        precision: 10, scale: 5
    t.decimal  "ZMK",        precision: 10, scale: 5
    t.decimal  "ZMW",        precision: 10, scale: 5
    t.decimal  "ZWL",        precision: 10, scale: 5
  end

  add_index "currency_conversion_rates", ["date"], name: "index_currency_conversion_rates_on_date", using: :btree

  create_table "custom_fields", force: :cascade do |t|
    t.integer  "field_configuration_id", limit: 4,   null: false
    t.integer  "parent_id",              limit: 4
    t.string   "parent_type",            limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "value_id",               limit: 4
    t.string   "value_type",             limit: 255
  end

  add_index "custom_fields", ["field_configuration_id"], name: "index_custom_fields_on_field_configuration_id", using: :btree
  add_index "custom_fields", ["parent_id"], name: "index_custom_fields_on_parent_id", using: :btree
  add_index "custom_fields", ["parent_type"], name: "index_custom_fields_on_parent_type", using: :btree

  create_table "distance_expense_configs", force: :cascade do |t|
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.boolean  "enabled"
    t.integer  "default_category_id", limit: 4
    t.integer  "rate_id",             limit: 4
    t.integer  "distance_unit_id",    limit: 4
    t.integer  "policy_id",           limit: 4, null: false
  end

  create_table "distance_expenses", force: :cascade do |t|
    t.integer  "expense_id",  limit: 4
    t.boolean  "is_deleted",            default: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "distance_id", limit: 4
  end

  add_index "distance_expenses", ["expense_id"], name: "index_distance_expenses_on_expense_id", using: :btree

  create_table "distances", force: :cascade do |t|
    t.decimal  "value",                      precision: 10, scale: 4
    t.integer  "physical_unit_id", limit: 4
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  add_index "distances", ["physical_unit_id"], name: "index_distances_on_physical_unit_id", using: :btree

  create_table "duplicate_expense_mappings", force: :cascade do |t|
    t.integer  "expense_id",           limit: 4, null: false
    t.integer  "duplicate_expense_id", limit: 4, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "duplicate_expense_mappings", ["expense_id"], name: "index_duplicate_expense_mappings_on_expense_id", using: :btree

  create_table "email_authorizations", force: :cascade do |t|
    t.integer "user_id",           limit: 4
    t.integer "authorizable_id",   limit: 4,                  null: false
    t.string  "authorizable_type", limit: 255,                null: false
    t.string  "token",             limit: 255
    t.boolean "is_valid",                      default: true
    t.integer "view_role_id",      limit: 4
  end

  add_index "email_authorizations", ["authorizable_id"], name: "index_email_authorizations_on_authorizable_id", using: :btree
  add_index "email_authorizations", ["authorizable_type"], name: "index_email_authorizations_on_authorizable_type", using: :btree
  add_index "email_authorizations", ["token"], name: "index_email_authorizations_on_token", using: :btree
  add_index "email_authorizations", ["user_id"], name: "index_email_authorizations_on_user_id", using: :btree

  create_table "enforce_policies", force: :cascade do |t|
    t.integer  "enforceable_id",   limit: 4,   null: false
    t.string   "enforceable_type", limit: 255, null: false
    t.boolean  "enabled"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "enforce_policies", ["enforceable_type", "enforceable_id"], name: "index_enforce_policies_on_enforceable_type_and_enforceable_id", using: :btree

  create_table "expense_data_extract_sources", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "expense_data_extract_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "expense_data_extracts", force: :cascade do |t|
    t.string   "merchant",                       limit: 255
    t.string   "reference_id",                   limit: 255
    t.time     "time"
    t.integer  "amount_id",                      limit: 4
    t.integer  "category_id",                    limit: 4
    t.integer  "sourcable_id",                   limit: 4
    t.string   "sourcable_type",                 limit: 255
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "extractable_id",                 limit: 4,     null: false
    t.string   "extractable_type",               limit: 255,   null: false
    t.text     "note",                           limit: 65535
    t.datetime "datetime"
    t.integer  "expense_data_extract_source_id", limit: 4
    t.integer  "status_id",                      limit: 4,     null: false
  end

  add_index "expense_data_extracts", ["amount_id"], name: "index_expense_data_extracts_on_amount_id", using: :btree
  add_index "expense_data_extracts", ["category_id"], name: "index_expense_data_extracts_on_category_id", using: :btree
  add_index "expense_data_extracts", ["sourcable_id"], name: "index_expense_data_extracts_on_sourcable_id", using: :btree
  add_index "expense_data_extracts", ["sourcable_type"], name: "index_expense_data_extracts_on_sourcable_type", using: :btree

  create_table "expense_rule_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "expense_rules", force: :cascade do |t|
    t.integer  "greater_than_amount_id", limit: 4
    t.integer  "category_id",            limit: 4
    t.integer  "days_after",             limit: 4
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "rule_type_id",           limit: 4
    t.integer  "expense_rule_type_id",   limit: 4
    t.integer  "policy_id",              limit: 4
  end

  add_index "expense_rules", ["category_id"], name: "index_expense_rules_on_category_id", using: :btree
  add_index "expense_rules", ["expense_rule_type_id"], name: "index_expense_rules_on_expense_rule_type_id", using: :btree
  add_index "expense_rules", ["greater_than_amount_id"], name: "index_expense_rules_on_greater_than_amount_id", using: :btree
  add_index "expense_rules", ["policy_id"], name: "index_expense_rules_on_policy_id", using: :btree
  add_index "expense_rules", ["rule_type_id"], name: "index_expense_rules_on_rule_type_id", using: :btree

  create_table "expense_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "order",      limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "expense_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "expenses", force: :cascade do |t|
    t.integer  "amount_id",            limit: 4
    t.integer  "expense_status_id",    limit: 4
    t.text     "note",                 limit: 65535
    t.date     "date"
    t.integer  "user_id",              limit: 4
    t.integer  "expense_type_id",      limit: 4
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.text     "manager_memo",         limit: 65535
    t.integer  "rejecting_manager_id", limit: 4
    t.integer  "report_id",            limit: 4
    t.integer  "category_id",          limit: 4
    t.boolean  "is_deleted",                         default: false, null: false
    t.boolean  "transcribed",                        default: false
    t.boolean  "personal",                           default: false
    t.boolean  "reimbursable",                       default: true
  end

  add_index "expenses", ["amount_id"], name: "index_expenses_on_amount_id", using: :btree
  add_index "expenses", ["category_id"], name: "index_expenses_on_category_id", using: :btree
  add_index "expenses", ["expense_status_id"], name: "index_expenses_on_expense_status_id", using: :btree
  add_index "expenses", ["expense_type_id"], name: "index_expenses_on_expense_type_id", using: :btree
  add_index "expenses", ["report_id"], name: "index_expenses_on_report_id", using: :btree
  add_index "expenses", ["user_id"], name: "index_expenses_on_user_id", using: :btree

  create_table "export_fields", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "export_preferences", force: :cascade do |t|
    t.integer  "company_id",      limit: 4,   null: false
    t.integer  "export_field_id", limit: 4,   null: false
    t.string   "name",            limit: 255, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "export_preferences", ["company_id"], name: "index_export_preferences_on_company_id", using: :btree
  add_index "export_preferences", ["export_field_id"], name: "index_export_preferences_on_export_field_id", using: :btree

  create_table "feature_subscriptions", force: :cascade do |t|
    t.integer  "subscribable_id",            limit: 4,                   null: false
    t.string   "subscribable_type",          limit: 255,                 null: false
    t.boolean  "ocr_enabled",                            default: false, null: false
    t.boolean  "expense_management_enabled",             default: false, null: false
    t.boolean  "gift_card_enabled",                      default: false, null: false
    t.boolean  "gift_voucher_enabled",                   default: false, null: false
    t.boolean  "meal_card_enabled",                      default: false, null: false
    t.boolean  "fuel_card_enabled",                      default: false, null: false
    t.boolean  "medical_card_enabled",                   default: false, null: false
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.boolean  "expense_card_enabled",                   default: false
    t.boolean  "reimbursement_card_enabled",             default: false
    t.boolean  "hard_copy_receipt",                      default: false
    t.boolean  "itz_cash_d_code_enabled",                default: false
    t.boolean  "yes_bank_account"
  end

  add_index "feature_subscriptions", ["subscribable_id"], name: "index_feature_subscriptions_on_subscribable_id", using: :btree
  add_index "feature_subscriptions", ["subscribable_type"], name: "index_feature_subscriptions_on_subscribable_type", using: :btree

  create_table "feedback_types", force: :cascade do |t|
    t.string   "name",        limit: 255,   null: false
    t.text     "description", limit: 65535, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "feedbacks", force: :cascade do |t|
    t.integer  "feedback_type_id", limit: 4,     null: false
    t.text     "content",          limit: 65535, null: false
    t.integer  "user_id",          limit: 4,     null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "feedbacks", ["feedback_type_id"], name: "index_feedbacks_on_feedback_type_id", using: :btree
  add_index "feedbacks", ["user_id"], name: "index_feedbacks_on_user_id", using: :btree

  create_table "field_amounts", force: :cascade do |t|
    t.integer  "value_id",   limit: 4, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "field_amounts", ["value_id"], name: "index_field_amounts_on_value_id", using: :btree

  create_table "field_booleans", force: :cascade do |t|
    t.boolean  "value",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "field_configurations", force: :cascade do |t|
    t.boolean  "enabled",                          default: true,  null: false
    t.integer  "field_type_id",        limit: 4,                   null: false
    t.boolean  "mandatory",                        default: false, null: false
    t.integer  "company_id",           limit: 4,                   null: false
    t.integer  "field_parent_type_id", limit: 4,                   null: false
    t.integer  "configurable_id",      limit: 4,                   null: false
    t.string   "configurable_type",    limit: 255,                 null: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "field_name",           limit: 255,                 null: false
    t.integer  "default_value_id",     limit: 4
    t.string   "default_value_type",   limit: 255
    t.boolean  "is_deleted",                       default: false, null: false
  end

  add_index "field_configurations", ["company_id"], name: "index_field_configurations_on_company_id", using: :btree
  add_index "field_configurations", ["configurable_id"], name: "index_field_configurations_on_configurable_id", using: :btree
  add_index "field_configurations", ["configurable_type"], name: "index_field_configurations_on_configurable_type", using: :btree
  add_index "field_configurations", ["field_parent_type_id"], name: "index_field_configurations_on_field_parent_type_id", using: :btree
  add_index "field_configurations", ["field_type_id"], name: "index_field_configurations_on_field_type_id", using: :btree

  create_table "field_date_times", force: :cascade do |t|
    t.datetime "value",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "field_dates", force: :cascade do |t|
    t.date     "value",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "field_decimals", force: :cascade do |t|
    t.text     "value",      limit: 65535, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "field_drop_down_items", force: :cascade do |t|
    t.string   "name",                   limit: 255, null: false
    t.integer  "field_configuration_id", limit: 4,   null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "field_drop_down_items", ["field_configuration_id"], name: "index_field_drop_down_items_on_field_configuration_id", using: :btree

  create_table "field_drop_down_selections", force: :cascade do |t|
    t.integer  "value_id",   limit: 4, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "field_drop_down_selections", ["value_id"], name: "index_field_drop_down_selections_on_value_id", using: :btree

  create_table "field_numbers", force: :cascade do |t|
    t.text     "value",      limit: 65535, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "field_parent_types", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "field_texts", force: :cascade do |t|
    t.text     "value",      limit: 65535, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "field_types", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "finly_transactions", force: :cascade do |t|
    t.integer  "finly_account_id",            limit: 4,   null: false
    t.string   "finly_account_type",          limit: 255, null: false
    t.integer  "transaction_type_id",         limit: 4,   null: false
    t.integer  "amount_id",                   limit: 4,   null: false
    t.string   "transaction_reference_id",    limit: 255, null: false
    t.integer  "status_id",                   limit: 4,   null: false
    t.integer  "payment_purpose_id",          limit: 4,   null: false
    t.integer  "opening_balance_id",          limit: 4
    t.integer  "closing_balance_id",          limit: 4
    t.integer  "associated_transaction_id",   limit: 4
    t.string   "associated_transaction_type", limit: 255
    t.integer  "payment_id",                  limit: 4
    t.integer  "company_id",                  limit: 4
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.datetime "date"
  end

  add_index "finly_transactions", ["amount_id"], name: "index_finly_transactions_on_amount_id", using: :btree
  add_index "finly_transactions", ["associated_transaction_id"], name: "index_finly_transactions_on_associated_transaction_id", using: :btree
  add_index "finly_transactions", ["associated_transaction_type"], name: "index_finly_transactions_on_associated_transaction_type", using: :btree
  add_index "finly_transactions", ["closing_balance_id"], name: "index_finly_transactions_on_closing_balance_id", using: :btree
  add_index "finly_transactions", ["company_id"], name: "index_finly_transactions_on_company_id", using: :btree
  add_index "finly_transactions", ["finly_account_id"], name: "index_finly_transactions_on_finly_account_id", using: :btree
  add_index "finly_transactions", ["finly_account_type"], name: "index_finly_transactions_on_finly_account_type", using: :btree
  add_index "finly_transactions", ["opening_balance_id"], name: "index_finly_transactions_on_opening_balance_id", using: :btree
  add_index "finly_transactions", ["payment_id"], name: "index_finly_transactions_on_payment_id", using: :btree
  add_index "finly_transactions", ["payment_purpose_id"], name: "index_finly_transactions_on_payment_purpose_id", using: :btree
  add_index "finly_transactions", ["status_id"], name: "index_finly_transactions_on_status_id", using: :btree
  add_index "finly_transactions", ["transaction_reference_id"], name: "index_finly_transactions_on_transaction_reference_id", using: :btree
  add_index "finly_transactions", ["transaction_type_id"], name: "index_finly_transactions_on_transaction_type_id", using: :btree

  create_table "individual_kyc_track_actions", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "individual_kyc_track_actions", ["name"], name: "index_individual_kyc_track_actions_on_name", using: :btree

  create_table "individual_kyc_tracks", force: :cascade do |t|
    t.integer  "individual_kyc_id",    limit: 4,     null: false
    t.integer  "action_resource_id",   limit: 4
    t.string   "action_resource_type", limit: 255
    t.integer  "action_id",            limit: 4,     null: false
    t.text     "note",                 limit: 65535
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "individual_kyc_tracks", ["action_id"], name: "index_individual_kyc_tracks_on_action_id", using: :btree
  add_index "individual_kyc_tracks", ["action_resource_id"], name: "index_individual_kyc_tracks_on_action_resource_id", using: :btree
  add_index "individual_kyc_tracks", ["action_resource_type"], name: "index_individual_kyc_tracks_on_action_resource_type", using: :btree
  add_index "individual_kyc_tracks", ["individual_kyc_id"], name: "index_individual_kyc_tracks_on_individual_kyc_id", using: :btree

  create_table "individual_kyc_types", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "individual_kycs", force: :cascade do |t|
    t.string   "id_proof_file_name",         limit: 255
    t.string   "id_proof_content_type",      limit: 255
    t.integer  "id_proof_file_size",         limit: 4
    t.datetime "id_proof_updated_at"
    t.integer  "kyc_status_id",              limit: 4
    t.integer  "user_id",                    limit: 4,     null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "address_proof_file_name",    limit: 255
    t.string   "address_proof_content_type", limit: 255
    t.integer  "address_proof_file_size",    limit: 4
    t.datetime "address_proof_updated_at"
    t.integer  "review_position",            limit: 4
    t.integer  "admin_review_workflow_id",   limit: 4,     null: false
    t.integer  "upgraded_by_resource_id",    limit: 4
    t.string   "proof_file_1_file_name",     limit: 255
    t.string   "proof_file_1_content_type",  limit: 255
    t.integer  "proof_file_1_file_size",     limit: 4
    t.datetime "proof_file_1_updated_at"
    t.string   "proof_file_1",               limit: 255
    t.string   "proof_file_2_file_name",     limit: 255
    t.string   "proof_file_2_content_type",  limit: 255
    t.integer  "proof_file_2_file_size",     limit: 4
    t.datetime "proof_file_2_updated_at"
    t.string   "proof_file_2",               limit: 255
    t.integer  "type_id",                    limit: 4
    t.string   "kyc_file_1_file_name",       limit: 255
    t.string   "kyc_file_1_content_type",    limit: 255
    t.integer  "kyc_file_1_file_size",       limit: 4
    t.datetime "kyc_file_1_updated_at"
    t.string   "kyc_file_2_file_name",       limit: 255
    t.string   "kyc_file_2_content_type",    limit: 255
    t.integer  "kyc_file_2_file_size",       limit: 4
    t.datetime "kyc_file_2_updated_at"
    t.string   "kyc_number",                 limit: 255
    t.integer  "company_id",                 limit: 4,     null: false
    t.text     "admin_note",                 limit: 65535
    t.datetime "submitted_on"
    t.datetime "upgraded_on"
  end

  add_index "individual_kycs", ["admin_review_workflow_id"], name: "index_individual_kycs_on_admin_review_workflow_id", using: :btree
  add_index "individual_kycs", ["company_id"], name: "index_individual_kycs_on_company_id", using: :btree
  add_index "individual_kycs", ["user_id"], name: "index_individual_kycs_on_user_id", using: :btree

  create_table "itz_cash_card_programs", force: :cascade do |t|
    t.string   "product_code", limit: 255
    t.string   "charge_code",  limit: 255
    t.string   "name",         limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "bank",         limit: 255
  end

  create_table "itz_cash_company_accounts", force: :cascade do |t|
    t.integer  "company_id",        limit: 4
    t.integer  "wallet_balance_id", limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "balance_id",        limit: 4
  end

  add_index "itz_cash_company_accounts", ["company_id"], name: "index_itz_cash_company_accounts_on_company_id", using: :btree

  create_table "itz_cash_dmt_beneficiaries", force: :cascade do |t|
    t.string   "first_name",             limit: 255,                 null: false
    t.string   "middle_name",            limit: 255
    t.string   "last_name",              limit: 255,                 null: false
    t.string   "mobile_number",          limit: 255,                 null: false
    t.string   "relation",               limit: 255,                 null: false
    t.string   "ifsc_option",            limit: 255,                 null: false
    t.string   "ifsc_code",              limit: 255,                 null: false
    t.string   "bank_name",              limit: 255
    t.string   "branch_name",            limit: 255
    t.string   "bank_city",              limit: 255
    t.string   "bank_state",             limit: 255
    t.string   "account_number",         limit: 255,                 null: false
    t.string   "beneficiary_name",       limit: 255,                 null: false
    t.string   "beneficiary_id",         limit: 255,                 null: false
    t.boolean  "is_updatable",                                       null: false
    t.integer  "itz_cash_dmt_sender_id", limit: 4,                   null: false
    t.integer  "status_id",              limit: 4,                   null: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.boolean  "default"
    t.boolean  "reimbursement",                      default: false
  end

  add_index "itz_cash_dmt_beneficiaries", ["itz_cash_dmt_sender_id"], name: "index_itz_cash_dmt_beneficiaries_on_itz_cash_dmt_sender_id", using: :btree
  add_index "itz_cash_dmt_beneficiaries", ["status_id"], name: "index_itz_cash_dmt_beneficiaries_on_status_id", using: :btree

  create_table "itz_cash_dmt_beneficiary_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "itz_cash_dmt_sender_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "itz_cash_dmt_senders", force: :cascade do |t|
    t.string   "mobile_number",   limit: 255,                 null: false
    t.string   "registration_id", limit: 255,                 null: false
    t.integer  "user_id",         limit: 4,                   null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "status_id",       limit: 4,                   null: false
    t.boolean  "otp_verified",                default: false, null: false
  end

  add_index "itz_cash_dmt_senders", ["user_id"], name: "index_itz_cash_dmt_senders_on_user_id", using: :btree

  create_table "itz_cash_properties", force: :cascade do |t|
    t.string   "d_code",          limit: 255
    t.string   "easy_account_no", limit: 255
    t.integer  "company_id",      limit: 4,   null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "itz_cash_properties", ["company_id"], name: "index_itz_cash_properties_on_company_id", using: :btree

  create_table "kyc_documents", force: :cascade do |t|
    t.integer  "company_kyc_document_type_id", limit: 4
    t.integer  "company_kyc_id",               limit: 4
    t.string   "doc_file_name",                limit: 255
    t.string   "doc_content_type",             limit: 255
    t.integer  "doc_file_size",                limit: 4
    t.datetime "doc_updated_at"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "identifier",                   limit: 255
  end

  add_index "kyc_documents", ["company_kyc_document_type_id"], name: "index_kyc_documents_on_company_kyc_document_type_id", using: :btree
  add_index "kyc_documents", ["company_kyc_id"], name: "index_kyc_documents_on_company_kyc_id", using: :btree

  create_table "kyc_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "locations", force: :cascade do |t|
    t.integer  "locatable_id",   limit: 4
    t.string   "locatable_type", limit: 255
    t.decimal  "latitude",                     precision: 30, scale: 15
    t.decimal  "longitude",                    precision: 30, scale: 15
    t.string   "name",           limit: 255
    t.text     "address",        limit: 65535
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.integer  "order",          limit: 4
    t.string   "maps_id",        limit: 255
  end

  add_index "locations", ["locatable_id"], name: "index_locations_on_locatable_id", using: :btree
  add_index "locations", ["locatable_type"], name: "index_locations_on_locatable_type", using: :btree

  create_table "login_agreement_mappings", force: :cascade do |t|
    t.integer  "user_id",      limit: 4, null: false
    t.integer  "agreement_id", limit: 4, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "login_agreement_mappings", ["agreement_id"], name: "index_login_agreement_mappings_on_agreement_id", using: :btree
  add_index "login_agreement_mappings", ["user_id"], name: "index_login_agreement_mappings_on_user_id", using: :btree

  create_table "manual_expenses", force: :cascade do |t|
    t.integer  "expense_id", limit: 4
    t.string   "merchant",   limit: 255
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "is_deleted",             default: false
  end

  add_index "manual_expenses", ["expense_id"], name: "index_manual_expenses_on_expense_id", using: :btree

  create_table "mcc_category_mappings", force: :cascade do |t|
    t.integer  "category_id", limit: 4
    t.string   "mcc_code",    limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "mcc_category_mappings", ["category_id"], name: "index_mcc_category_mappings_on_category_id", using: :btree

  create_table "mcc_groups", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "code",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "money_request_actions", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "money_request_comment_actions", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "money_request_comments", force: :cascade do |t|
    t.integer  "money_request_id",  limit: 4,     null: false
    t.integer  "comment_action_id", limit: 4,     null: false
    t.integer  "user_id",           limit: 4
    t.integer  "expense_id",        limit: 4
    t.integer  "payment_id",        limit: 4
    t.string   "updated_field",     limit: 255
    t.text     "updated_from",      limit: 65535
    t.text     "updated_to",        limit: 65535
    t.integer  "rejected_to_id",    limit: 4
    t.text     "content",           limit: 65535
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "money_request_comments", ["comment_action_id"], name: "index_money_request_comments_on_comment_action_id", using: :btree
  add_index "money_request_comments", ["expense_id"], name: "index_money_request_comments_on_expense_id", using: :btree
  add_index "money_request_comments", ["money_request_id"], name: "index_money_request_comments_on_money_request_id", using: :btree
  add_index "money_request_comments", ["payment_id"], name: "index_money_request_comments_on_payment_id", using: :btree
  add_index "money_request_comments", ["rejected_to_id"], name: "index_money_request_comments_on_rejected_to_id", using: :btree
  add_index "money_request_comments", ["user_id"], name: "index_money_request_comments_on_user_id", using: :btree

  create_table "money_request_items", force: :cascade do |t|
    t.integer  "money_request_id", limit: 4, null: false
    t.integer  "category_id",      limit: 4, null: false
    t.integer  "amount_id",        limit: 4, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "money_request_items", ["amount_id"], name: "index_money_request_items_on_amount_id", using: :btree
  add_index "money_request_items", ["category_id"], name: "index_money_request_items_on_category_id", using: :btree
  add_index "money_request_items", ["money_request_id"], name: "index_money_request_items_on_money_request_id", using: :btree

  create_table "money_request_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "order",      limit: 4,   default: 1, null: false
  end

  create_table "money_request_tracking_actions", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "money_request_tracks", force: :cascade do |t|
    t.integer  "money_request_id",                 limit: 4,   null: false
    t.integer  "action_user_id",                   limit: 4
    t.integer  "modified_user_id",                 limit: 4
    t.integer  "money_request_tracking_action_id", limit: 4
    t.integer  "status_id",                        limit: 4
    t.integer  "modified_user_role_id",            limit: 4
    t.integer  "payment_id",                       limit: 4
    t.string   "memo",                             limit: 255
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "action_id",                        limit: 4
    t.integer  "action_user_role_id",              limit: 4
  end

  add_index "money_request_tracks", ["action_user_id"], name: "index_money_request_tracks_on_action_user_id", using: :btree
  add_index "money_request_tracks", ["modified_user_id"], name: "index_money_request_tracks_on_modified_user_id", using: :btree
  add_index "money_request_tracks", ["modified_user_role_id"], name: "index_money_request_tracks_on_modified_user_role_id", using: :btree
  add_index "money_request_tracks", ["money_request_id"], name: "index_money_request_tracks_on_money_request_id", using: :btree
  add_index "money_request_tracks", ["money_request_tracking_action_id"], name: "index_money_request_tracks_on_money_request_tracking_action_id", using: :btree
  add_index "money_request_tracks", ["payment_id"], name: "index_money_request_tracks_on_payment_id", using: :btree
  add_index "money_request_tracks", ["status_id"], name: "index_money_request_tracks_on_status_id", using: :btree

  create_table "money_requests", force: :cascade do |t|
    t.string   "name",                         limit: 255
    t.integer  "user_id",                      limit: 4,                                 null: false
    t.integer  "policy_id",                    limit: 4,                                 null: false
    t.integer  "payment_mode_id",              limit: 4,                                 null: false
    t.integer  "payment_id",                   limit: 4
    t.date     "required_by_date"
    t.integer  "status_id",                    limit: 4,                                 null: false
    t.integer  "controlling_user_id",          limit: 4
    t.integer  "controlling_user_role_id",     limit: 4
    t.integer  "controlling_for_user_id",      limit: 4
    t.integer  "controlling_for_user_role_id", limit: 4
    t.integer  "loaded_by",                    limit: 4
    t.datetime "loaded_at"
    t.datetime "submitted_at",                             precision: 6
    t.string   "memo",                         limit: 255
    t.boolean  "accounted",                                              default: false, null: false
    t.datetime "created_at",                                                             null: false
    t.datetime "updated_at",                                                             null: false
    t.boolean  "is_deleted",                                             default: false, null: false
    t.integer  "submitted_amount_id",          limit: 4
  end

  add_index "money_requests", ["controlling_for_user_id"], name: "index_money_requests_on_controlling_for_user_id", using: :btree
  add_index "money_requests", ["controlling_for_user_role_id"], name: "index_money_requests_on_controlling_for_user_role_id", using: :btree
  add_index "money_requests", ["controlling_user_id"], name: "index_money_requests_on_controlling_user_id", using: :btree
  add_index "money_requests", ["controlling_user_role_id"], name: "index_money_requests_on_controlling_user_role_id", using: :btree
  add_index "money_requests", ["loaded_by"], name: "index_money_requests_on_loaded_by", using: :btree
  add_index "money_requests", ["name"], name: "index_money_requests_on_name", using: :btree
  add_index "money_requests", ["payment_id"], name: "index_money_requests_on_payment_id", using: :btree
  add_index "money_requests", ["payment_mode_id"], name: "index_money_requests_on_payment_mode_id", using: :btree
  add_index "money_requests", ["policy_id"], name: "index_money_requests_on_policy_id", using: :btree
  add_index "money_requests", ["status_id"], name: "index_money_requests_on_status_id", using: :btree
  add_index "money_requests", ["user_id"], name: "index_money_requests_on_user_id", using: :btree

  create_table "new_card_requests", force: :cascade do |t|
    t.integer  "company_id",         limit: 4
    t.integer  "requesting_user_id", limit: 4
    t.integer  "card_type_id",       limit: 4
    t.integer  "status_id",          limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "new_card_requests", ["card_type_id"], name: "index_new_card_requests_on_card_type_id", using: :btree
  add_index "new_card_requests", ["company_id"], name: "index_new_card_requests_on_company_id", using: :btree
  add_index "new_card_requests", ["requesting_user_id"], name: "index_new_card_requests_on_requesting_user_id", using: :btree
  add_index "new_card_requests", ["status_id"], name: "index_new_card_requests_on_status_id", using: :btree

  create_table "notification_action_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "notification_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "notification_type_id", limit: 4
    t.integer  "user_id",              limit: 4
    t.integer  "action_user_id",       limit: 4
    t.integer  "amount_id",            limit: 4
    t.integer  "object_id",            limit: 4
    t.string   "object_type",          limit: 255
    t.integer  "path_object_id",       limit: 4
    t.string   "path_object_type",     limit: 255
    t.integer  "action_type_id",       limit: 4
    t.string   "changed_from",         limit: 255
    t.string   "changed_to",           limit: 255
    t.datetime "timestamp"
    t.boolean  "read",                               default: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.text     "link",                 limit: 65535
    t.integer  "view_role_id",         limit: 4
    t.text     "message",              limit: 65535
  end

  add_index "notifications", ["action_type_id"], name: "index_notifications_on_action_type_id", using: :btree
  add_index "notifications", ["action_user_id"], name: "index_notifications_on_action_user_id", using: :btree
  add_index "notifications", ["amount_id"], name: "index_notifications_on_amount_id", using: :btree
  add_index "notifications", ["notification_type_id"], name: "index_notifications_on_notification_type_id", using: :btree
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "notifier_type_configurations", force: :cascade do |t|
    t.integer  "user_id",                 limit: 4, null: false
    t.integer  "event_id",                limit: 4, null: false
    t.boolean  "allow_push_notification"
    t.boolean  "allow_mailer"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "notifier_type_configurations", ["event_id"], name: "index_notifier_type_configurations_on_event_id", using: :btree
  add_index "notifier_type_configurations", ["user_id"], name: "index_notifier_type_configurations_on_user_id", using: :btree

  create_table "notifier_types", force: :cascade do |t|
    t.string   "name",                           limit: 255, null: false
    t.boolean  "has_push_notification",                      null: false
    t.boolean  "has_mailer",                                 null: false
    t.boolean  "configurable_push_notification",             null: false
    t.boolean  "configurable_mailer",                        null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", limit: 4,     null: false
    t.integer  "application_id",    limit: 4,     null: false
    t.string   "token",             limit: 255,   null: false
    t.integer  "expires_in",        limit: 4,     null: false
    t.text     "redirect_uri",      limit: 65535, null: false
    t.datetime "created_at",                      null: false
    t.datetime "revoked_at"
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_grants", ["application_id"], name: "fk_rails_b4b53e07b8", using: :btree
  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id",      limit: 4
    t.integer  "application_id",         limit: 4
    t.string   "token",                  limit: 255,              null: false
    t.string   "refresh_token",          limit: 255
    t.integer  "expires_in",             limit: 4
    t.datetime "revoked_at"
    t.datetime "created_at",                                      null: false
    t.string   "scopes",                 limit: 255
    t.string   "previous_refresh_token", limit: 255, default: "", null: false
  end

  add_index "oauth_access_tokens", ["application_id"], name: "fk_rails_732cb83ab7", using: :btree
  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",         limit: 255,                null: false
    t.string   "uid",          limit: 255,                null: false
    t.string   "secret",       limit: 255,                null: false
    t.text     "redirect_uri", limit: 65535,              null: false
    t.string   "scopes",       limit: 255,   default: "", null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "opro_auth_grants", force: :cascade do |t|
    t.string   "code",                    limit: 255
    t.string   "access_token",            limit: 255
    t.string   "refresh_token",           limit: 255
    t.text     "permissions",             limit: 65535
    t.datetime "access_token_expires_at"
    t.integer  "user_id",                 limit: 4
    t.integer  "application_id",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "opro_auth_grants", ["access_token"], name: "index_opro_auth_grants_on_access_token", unique: true, using: :btree
  add_index "opro_auth_grants", ["code"], name: "index_opro_auth_grants_on_code", unique: true, using: :btree
  add_index "opro_auth_grants", ["refresh_token"], name: "index_opro_auth_grants_on_refresh_token", unique: true, using: :btree

  create_table "opro_client_apps", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "app_id",      limit: 255
    t.string   "app_secret",  limit: 255
    t.text     "permissions", limit: 65535
    t.integer  "user_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "opro_client_apps", ["app_id", "app_secret"], name: "index_opro_client_apps_on_app_id_and_app_secret", unique: true, using: :btree
  add_index "opro_client_apps", ["app_id"], name: "index_opro_client_apps_on_app_id", unique: true, using: :btree

  create_table "otp_request_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "payment_modes", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "payment_order_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "payment_order_types", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "payment_orders", force: :cascade do |t|
    t.date     "scheduled_at"
    t.datetime "processed_at"
    t.integer  "initiating_user_id",        limit: 4,     null: false
    t.integer  "payment_order_status_id",   limit: 4,     null: false
    t.string   "payment_file_file_name",    limit: 255
    t.string   "payment_file_content_type", limit: 255
    t.integer  "payment_file_file_size",    limit: 4
    t.datetime "payment_file_updated_at"
    t.integer  "company_id",                limit: 4,     null: false
    t.integer  "amount_requested_id",       limit: 4
    t.integer  "amount_processed_id",       limit: 4
    t.text     "note",                      limit: 65535
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "initiating_account_type",   limit: 255
    t.string   "receiving_account_type",    limit: 255
    t.integer  "payment_purpose_id",        limit: 4,     null: false
    t.integer  "currency_id",               limit: 4,     null: false
    t.string   "application",               limit: 255
  end

  add_index "payment_orders", ["amount_processed_id"], name: "index_payment_orders_on_amount_processed_id", using: :btree
  add_index "payment_orders", ["amount_requested_id"], name: "index_payment_orders_on_amount_requested_id", using: :btree
  add_index "payment_orders", ["company_id"], name: "index_payment_orders_on_company_id", using: :btree
  add_index "payment_orders", ["initiating_user_id"], name: "index_payment_orders_on_initiating_user_id", using: :btree
  add_index "payment_orders", ["payment_order_status_id"], name: "index_payment_orders_on_payment_order_status_id", using: :btree

  create_table "payment_purposes", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "payment_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "payment_trails", force: :cascade do |t|
    t.date     "date"
    t.integer  "initiating_account_id",   limit: 4
    t.integer  "receiving_account_id",    limit: 4
    t.string   "initiating_account_type", limit: 255
    t.string   "receiving_account_type",  limit: 255
    t.integer  "payment_status_id",       limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "payment_id",              limit: 4
    t.integer  "initiating_user_id",      limit: 4
    t.string   "initiating_user_type",    limit: 255
    t.integer  "receiving_user_id",       limit: 4
    t.string   "receiving_user_type",     limit: 255
  end

  add_index "payment_trails", ["initiating_account_id"], name: "index_payment_trails_on_initiating_account_id", using: :btree
  add_index "payment_trails", ["receiving_account_id"], name: "index_payment_trails_on_receiving_account_id", using: :btree

  create_table "payment_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "payments", force: :cascade do |t|
    t.integer  "amount_id",               limit: 4,     null: false
    t.date     "date",                                  null: false
    t.integer  "payment_type_id",         limit: 4,     null: false
    t.integer  "initiating_user_id",      limit: 4,     null: false
    t.integer  "receiving_user_id",       limit: 4
    t.text     "note",                    limit: 65535
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "initiating_account_id",   limit: 4
    t.string   "initiating_account_type", limit: 255
    t.integer  "receiving_account_id",    limit: 4
    t.string   "receiving_account_type",  limit: 255
    t.integer  "payment_order_id",        limit: 4
    t.integer  "payment_status_id",       limit: 4,     null: false
    t.string   "initiating_user_type",    limit: 255
    t.string   "receiving_user_type",     limit: 255
    t.integer  "payment_purpose_id",      limit: 4
    t.integer  "reference_resource_id",   limit: 4
    t.string   "reference_resource_type", limit: 255
    t.string   "application",             limit: 255
    t.string   "payment_mode",            limit: 255
    t.string   "reference_id",            limit: 255,   null: false
  end

  add_index "payments", ["amount_id"], name: "index_payments_on_amount_id", using: :btree
  add_index "payments", ["initiating_user_id"], name: "index_payments_on_initiating_user_id", using: :btree
  add_index "payments", ["payment_type_id"], name: "index_payments_on_payment_type_id", using: :btree
  add_index "payments", ["receiving_user_id"], name: "index_payments_on_receiving_user_id", using: :btree

  create_table "per_diem_expense_configs", force: :cascade do |t|
    t.boolean  "enabled"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "policy_id",  limit: 4, null: false
  end

  create_table "per_diem_expenses", force: :cascade do |t|
    t.integer  "per_diem_id", limit: 4
    t.integer  "expense_id",  limit: 4
    t.decimal  "quantity",              precision: 10, scale: 4
    t.boolean  "is_deleted"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "per_diem_expenses", ["expense_id"], name: "index_per_diem_expenses_on_expense_id", using: :btree
  add_index "per_diem_expenses", ["per_diem_id"], name: "index_per_diem_expenses_on_per_diem_id", using: :btree

  create_table "per_diems", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.integer  "rate_id",           limit: 4
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "configurable_id",   limit: 4
    t.string   "configurable_type", limit: 255
    t.boolean  "is_deleted",                    default: false
  end

  add_index "per_diems", ["rate_id"], name: "index_per_diems_on_rate_id", using: :btree

  create_table "periods", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "physical_units", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "symbol",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "pin_code_city_id_mappings", force: :cascade do |t|
    t.string   "pin_code",   limit: 255
    t.string   "city_id",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "policies", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.integer  "company_id",       limit: 4
    t.integer  "owner_id",         limit: 4
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.boolean  "default",                        default: false, null: false
    t.boolean  "is_deleted",                     default: false, null: false
    t.text     "description",      limit: 65535
    t.integer  "base_currency_id", limit: 4,     default: 1
  end

  add_index "policies", ["company_id"], name: "index_policies_on_company_id", using: :btree
  add_index "policies", ["owner_id"], name: "index_policies_on_owner_id", using: :btree

  create_table "policy_configurations", force: :cascade do |t|
    t.integer  "policy_id",               limit: 4,                 null: false
    t.boolean  "require_category",                  default: false, null: false
    t.boolean  "default_billable_set",              default: false, null: false
    t.integer  "report_currency_id",      limit: 4
    t.integer  "technical_contact_id",    limit: 4
    t.boolean  "mandate_expense_tagging",           default: false, null: false
    t.integer  "default_tag_id",          limit: 4
    t.boolean  "active",                            default: true,  null: false
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  add_index "policy_configurations", ["default_tag_id"], name: "index_policy_configurations_on_default_tag_id", using: :btree
  add_index "policy_configurations", ["policy_id"], name: "index_policy_configurations_on_policy_id", using: :btree
  add_index "policy_configurations", ["report_currency_id"], name: "index_policy_configurations_on_report_currency_id", using: :btree
  add_index "policy_configurations", ["technical_contact_id"], name: "index_policy_configurations_on_technical_contact_id", using: :btree

  create_table "policy_user_mappings", force: :cascade do |t|
    t.integer  "user_id",    limit: 4,                 null: false
    t.integer  "policy_id",  limit: 4,                 null: false
    t.boolean  "admin",                default: false, null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "policy_user_mappings", ["policy_id"], name: "index_policy_user_mappings_on_policy_id", using: :btree
  add_index "policy_user_mappings", ["user_id"], name: "index_policy_user_mappings_on_user_id", using: :btree

  create_table "preview_registrations", force: :cascade do |t|
    t.string   "email",              limit: 255
    t.text     "company",            limit: 65535
    t.string   "phone_number",       limit: 255
    t.text     "name",               limit: 65535
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.text     "source",             limit: 65535
    t.text     "source_description", limit: 65535
  end

  create_table "product_combinations", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "quickbooks_categories", force: :cascade do |t|
    t.integer  "category_id",                       limit: 4
    t.string   "quickbooks_category_type",          limit: 255
    t.string   "quickbooks_id",                     limit: 255
    t.string   "quickbooks_integration_type",       limit: 255
    t.datetime "quickbooks_updated_at"
    t.text     "quickbooks_additional_information", limit: 16777215
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.integer  "company_id",                        limit: 4
  end

  create_table "quickbooks_company_tag", force: :cascade do |t|
    t.integer  "company_tags_id",                 limit: 4
    t.string   "quickbooks_tag_type",             limit: 255
    t.string   "quickbooks_integration_type",     limit: 255
    t.string   "quickbooks_id",                   limit: 255
    t.text     "quickbooks_external_information", limit: 16777215
    t.datetime "quickbooks_updated_at"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  create_table "quickbooks_configurations", force: :cascade do |t|
    t.string   "default_quickbooks_payment_type", limit: 255
    t.integer  "user_id",                         limit: 4
    t.boolean  "auto_import"
    t.boolean  "auto_export"
    t.integer  "transaction_date_field",          limit: 4
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "quickbooks_payment_type_id",      limit: 4
    t.integer  "reimbursable_account_id",         limit: 4
    t.integer  "non_reimbursable_account_id",     limit: 4
    t.integer  "company_id",                      limit: 4
  end

  add_index "quickbooks_configurations", ["quickbooks_payment_type_id"], name: "index_quickbooks_configurations_on_quickbooks_payment_type_id", using: :btree
  add_index "quickbooks_configurations", ["user_id"], name: "index_quickbooks_configurations_on_user_id", using: :btree

  create_table "quickbooks_finly_integrations_users", force: :cascade do |t|
    t.string   "email",                             limit: 255
    t.string   "name",                              limit: 255
    t.string   "mobile_number",                     limit: 255
    t.string   "quickbooks_id",                     limit: 255
    t.string   "quickbooks_integration_type",       limit: 255
    t.datetime "quickbooks_updated_at"
    t.boolean  "active"
    t.text     "quickbooks_additional_information", limit: 65535
    t.integer  "user_id",                           limit: 4
    t.integer  "company_id",                        limit: 4
    t.string   "quickbooks_user_type",              limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "quickbooks_finly_integrations_users", ["company_id"], name: "index_quickbooks_finly_integrations_users_on_company_id", using: :btree
  add_index "quickbooks_finly_integrations_users", ["user_id"], name: "index_quickbooks_finly_integrations_users_on_user_id", using: :btree

  create_table "quickbooks_payment_types", force: :cascade do |t|
    t.string   "name",                              limit: 255
    t.integer  "company_id",                        limit: 4
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "quickbooks_id",                     limit: 255
    t.string   "quickbooks_integration_type",       limit: 255
    t.datetime "quickbooks_updated_at"
    t.boolean  "active"
    t.text     "quickbooks_additional_information", limit: 65535
  end

  add_index "quickbooks_payment_types", ["company_id"], name: "index_quickbooks_payment_types_on_company_id", using: :btree

  create_table "receipt_email_attachments", force: :cascade do |t|
    t.integer  "receipt_email_id",                 limit: 4
    t.string   "original_attachment_file_name",    limit: 255
    t.string   "original_attachment_content_type", limit: 255
    t.integer  "original_attachment_file_size",    limit: 4
    t.datetime "original_attachment_updated_at"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.text     "attachment_url",                   limit: 65535
    t.string   "attachment_url_file_name",         limit: 255
  end

  add_index "receipt_email_attachments", ["receipt_email_id"], name: "index_receipt_email_attachments_on_receipt_email_id", using: :btree

  create_table "receipt_email_parse_failures", force: :cascade do |t|
    t.integer  "user_id",                      limit: 4
    t.string   "subject",                      limit: 255
    t.datetime "sent_at"
    t.string   "body_file_name",               limit: 255
    t.string   "body_content_type",            limit: 255
    t.integer  "body_file_size",               limit: 4
    t.datetime "body_updated_at"
    t.string   "raw_text_file_name",           limit: 255
    t.string   "raw_text_content_type",        limit: 255
    t.integer  "raw_text_file_size",           limit: 4
    t.datetime "raw_text_updated_at"
    t.string   "raw_html_file_name",           limit: 255
    t.string   "raw_html_content_type",        limit: 255
    t.integer  "raw_html_file_size",           limit: 4
    t.datetime "raw_html_updated_at"
    t.string   "raw_header_file_name",         limit: 255
    t.string   "raw_header_content_type",      limit: 255
    t.integer  "raw_header_file_size",         limit: 4
    t.datetime "raw_header_updated_at"
    t.string   "original_source_file_name",    limit: 255
    t.string   "original_source_content_type", limit: 255
    t.integer  "original_source_file_size",    limit: 4
    t.datetime "original_source_updated_at"
    t.string   "email_id",                     limit: 255
    t.string   "sender",                       limit: 255
    t.string   "source_file_name",             limit: 255
    t.string   "source_content_type",          limit: 255
    t.integer  "source_file_size",             limit: 4
    t.datetime "source_updated_at"
    t.boolean  "fixed",                                      default: false
    t.string   "parsed_merchant",              limit: 255
    t.string   "parsed_amount_value",          limit: 255
    t.integer  "parsed_currency_id",           limit: 4
    t.datetime "parsed_datetime"
    t.text     "parsed_note",                  limit: 65535
    t.integer  "parsed_category_id",           limit: 4
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
  end

  add_index "receipt_email_parse_failures", ["parsed_category_id"], name: "index_receipt_email_parse_failures_on_parsed_category_id", using: :btree
  add_index "receipt_email_parse_failures", ["parsed_currency_id"], name: "index_receipt_email_parse_failures_on_parsed_currency_id", using: :btree
  add_index "receipt_email_parse_failures", ["user_id"], name: "index_receipt_email_parse_failures_on_user_id", using: :btree

  create_table "receipt_emails", force: :cascade do |t|
    t.text     "subject",                      limit: 65535
    t.datetime "sent_at"
    t.integer  "user_id",                      limit: 4
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "body_file_name",               limit: 255
    t.string   "body_content_type",            limit: 255
    t.integer  "body_file_size",               limit: 4
    t.datetime "body_updated_at"
    t.string   "raw_text_file_name",           limit: 255
    t.string   "raw_text_content_type",        limit: 255
    t.integer  "raw_text_file_size",           limit: 4
    t.datetime "raw_text_updated_at"
    t.string   "raw_html_file_name",           limit: 255
    t.string   "raw_html_content_type",        limit: 255
    t.integer  "raw_html_file_size",           limit: 4
    t.datetime "raw_html_updated_at"
    t.string   "raw_header_file_name",         limit: 255
    t.string   "raw_header_content_type",      limit: 255
    t.integer  "raw_header_file_size",         limit: 4
    t.datetime "raw_header_updated_at"
    t.integer  "expense_id",                   limit: 4
    t.string   "email_id",                     limit: 255
    t.string   "sender",                       limit: 255
    t.string   "source",                       limit: 255
    t.string   "original_source_file_name",    limit: 255
    t.string   "original_source_content_type", limit: 255
    t.integer  "original_source_file_size",    limit: 4
    t.datetime "original_source_updated_at"
  end

  add_index "receipt_emails", ["expense_id"], name: "index_receipt_emails_on_expense_id", using: :btree
  add_index "receipt_emails", ["user_id"], name: "index_receipt_emails_on_user_id", using: :btree

  create_table "receipts", force: :cascade do |t|
    t.integer  "user_id",            limit: 4
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.integer  "parent_id",          limit: 4
    t.string   "parent_type",        limit: 255
    t.text     "note",               limit: 65535
    t.integer  "receipt_email_id",   limit: 4
    t.boolean  "to_be_transcribed",                default: false
    t.boolean  "hard_copy_received",               default: true
    t.integer  "sourcable_id",       limit: 4
    t.integer  "sourcable_type",     limit: 4
  end

  add_index "receipts", ["parent_type", "parent_id"], name: "index_receipts_on_parent_type_and_parent_id", using: :btree
  add_index "receipts", ["receipt_email_id"], name: "index_receipts_on_receipt_email_id", using: :btree
  add_index "receipts", ["user_id"], name: "index_receipts_on_user_id", using: :btree

  create_table "referrers", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "report_comment_actions", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "report_comments", force: :cascade do |t|
    t.integer  "report_id",                limit: 4,     null: false
    t.integer  "report_comment_action_id", limit: 4,     null: false
    t.integer  "user_id",                  limit: 4
    t.integer  "expense_id",               limit: 4
    t.string   "updated_field",            limit: 255
    t.text     "updated_from",             limit: 65535
    t.text     "updated_to",               limit: 65535
    t.integer  "rejected_to_id",           limit: 4
    t.text     "content",                  limit: 65535
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "payment_id",               limit: 4
  end

  add_index "report_comments", ["expense_id"], name: "index_report_comments_on_expense_id", using: :btree
  add_index "report_comments", ["rejected_to_id"], name: "index_report_comments_on_rejected_to_id", using: :btree
  add_index "report_comments", ["report_comment_action_id"], name: "index_report_comments_on_report_comment_action_id", using: :btree
  add_index "report_comments", ["report_id"], name: "index_report_comments_on_report_id", using: :btree
  add_index "report_comments", ["user_id"], name: "index_report_comments_on_user_id", using: :btree

  create_table "report_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.integer  "order",      limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "report_tracking_actions", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "report_tracks", force: :cascade do |t|
    t.integer  "report_id",                 limit: 4,   null: false
    t.integer  "action_user_id",            limit: 4
    t.integer  "modified_user_id",          limit: 4
    t.integer  "report_tracking_action_id", limit: 4
    t.integer  "report_status_id",          limit: 4,   null: false
    t.integer  "modified_user_role_id",     limit: 4
    t.string   "memo",                      limit: 255
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "payment_id",                limit: 4
    t.integer  "action_user_role_id",       limit: 4
    t.integer  "cash_in_hand_deduction_id", limit: 4
  end

  add_index "report_tracks", ["action_user_id"], name: "index_report_tracks_on_action_user_id", using: :btree
  add_index "report_tracks", ["modified_user_id"], name: "index_report_tracks_on_modified_user_id", using: :btree
  add_index "report_tracks", ["modified_user_role_id"], name: "index_report_tracks_on_modified_user_role_id", using: :btree
  add_index "report_tracks", ["report_id"], name: "index_report_tracks_on_report_id", using: :btree
  add_index "report_tracks", ["report_status_id"], name: "index_report_tracks_on_report_status_id", using: :btree
  add_index "report_tracks", ["report_tracking_action_id"], name: "index_report_tracks_on_report_tracking_action_id", using: :btree

  create_table "reports", force: :cascade do |t|
    t.string   "name",                               limit: 255,                               null: false
    t.integer  "user_id",                            limit: 4,                                 null: false
    t.integer  "report_status_id",                   limit: 4,                                 null: false
    t.integer  "policy_id",                          limit: 4,                                 null: false
    t.datetime "submitted_at",                                   precision: 6
    t.integer  "controlling_user_id",                limit: 4
    t.integer  "controlling_user_role_id",           limit: 4
    t.integer  "controlling_for_user_id",            limit: 4
    t.integer  "controlling_for_user_role_id",       limit: 4
    t.string   "memo",                               limit: 255
    t.datetime "created_at",                                                                   null: false
    t.datetime "updated_at",                                                                   null: false
    t.integer  "reimbursement_id",                   limit: 4
    t.boolean  "accounted",                                                    default: false, null: false
    t.boolean  "archived",                                                     default: false, null: false
    t.boolean  "is_deleted",                                                   default: false, null: false
    t.boolean  "auto_submit",                                                  default: false, null: false
    t.boolean  "auto_approve",                                                 default: false, null: false
    t.date     "accounted_at"
    t.datetime "approved_at"
    t.integer  "cash_in_hand_deduction_id",          limit: 4
    t.integer  "submitted_amount_id",                limit: 4
    t.integer  "reimbursable_expenses_total_id",     limit: 4
    t.integer  "card_expenses_total_id",             limit: 4
    t.integer  "non_reimbursable_expenses_total_id", limit: 4
    t.boolean  "synced_with_quickbooks"
  end

  add_index "reports", ["controlling_for_user_id"], name: "index_reports_on_controlling_for_user_id", using: :btree
  add_index "reports", ["controlling_for_user_role_id"], name: "index_reports_on_controlling_for_user_role_id", using: :btree
  add_index "reports", ["controlling_user_id"], name: "index_reports_on_controlling_user_id", using: :btree
  add_index "reports", ["controlling_user_role_id"], name: "index_reports_on_controlling_user_role_id", using: :btree
  add_index "reports", ["name"], name: "index_reports_on_name", using: :btree
  add_index "reports", ["policy_id"], name: "index_reports_on_policy_id", using: :btree
  add_index "reports", ["report_status_id"], name: "index_reports_on_report_status_id", using: :btree
  add_index "reports", ["user_id"], name: "index_reports_on_user_id", using: :btree

  create_table "resource_requests", force: :cascade do |t|
    t.string "name",               limit: 255
    t.string "email",              limit: 255
    t.string "mobile_number",      limit: 255
    t.string "resource_file_name", limit: 255
    t.text   "source",             limit: 65535
    t.text   "source_description", limit: 65535
  end

  create_table "rule_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "states", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.string   "code",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "system_message_types", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "system_messages", force: :cascade do |t|
    t.text     "content",                limit: 65535,                 null: false
    t.integer  "system_message_type_id", limit: 4,                     null: false
    t.integer  "messagable_id",          limit: 4
    t.string   "messagable_type",        limit: 255
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.boolean  "is_deleted",                           default: false
    t.string   "message_type",           limit: 255
  end

  add_index "system_messages", ["system_message_type_id"], name: "index_system_messages_on_system_message_type_id", using: :btree

  create_table "time_expense_configs", force: :cascade do |t|
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.boolean  "enabled"
    t.integer  "default_category_id", limit: 4
    t.integer  "rate_id",             limit: 4
    t.integer  "period_id",           limit: 4
    t.integer  "policy_id",           limit: 4, null: false
  end

  create_table "time_expenses", force: :cascade do |t|
    t.integer  "expense_id",     limit: 4
    t.boolean  "is_deleted"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "time_object_id", limit: 4
  end

  add_index "time_expenses", ["expense_id"], name: "index_time_expenses_on_expense_id", using: :btree

  create_table "time_objects", force: :cascade do |t|
    t.decimal  "value",                      precision: 10, scale: 4
    t.integer  "physical_unit_id", limit: 4
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  add_index "time_objects", ["physical_unit_id"], name: "index_time_objects_on_physical_unit_id", using: :btree

  create_table "transaction_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "transaction_types", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "transcribed_expenses", force: :cascade do |t|
    t.integer  "amount_id",  limit: 4
    t.date     "date"
    t.text     "merchant",   limit: 65535
    t.text     "note",       limit: 65535
    t.integer  "receipt_id", limit: 4
    t.integer  "expense_id", limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "transcribed_expenses", ["amount_id"], name: "index_transcribed_expenses_on_amount_id", using: :btree
  add_index "transcribed_expenses", ["expense_id"], name: "index_transcribed_expenses_on_expense_id", using: :btree
  add_index "transcribed_expenses", ["receipt_id"], name: "index_transcribed_expenses_on_receipt_id", using: :btree
  add_index "transcribed_expenses", ["user_id"], name: "index_transcribed_expenses_on_user_id", using: :btree

  create_table "user_balance_histories", force: :cascade do |t|
    t.date     "date"
    t.integer  "user_id",                    limit: 4
    t.integer  "company_id",                 limit: 4
    t.integer  "card_balance_id",            limit: 4
    t.integer  "card_withdrawal_id",         limit: 4
    t.integer  "card_load_id",               limit: 4
    t.integer  "card_expenses_id",           limit: 4
    t.integer  "finly_money_balance_id",     limit: 4
    t.integer  "finly_money_withdrawal_id",  limit: 4
    t.integer  "finly_money_load_id",        limit: 4
    t.integer  "cash_on_hand_balance_id",    limit: 4
    t.integer  "cash_on_hand_withdrawal_id", limit: 4
    t.integer  "cash_on_hand_load_id",       limit: 4
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "card_atm_withdrawal_id",     limit: 4
  end

  add_index "user_balance_histories", ["card_balance_id"], name: "index_user_balance_histories_on_card_balance_id", using: :btree
  add_index "user_balance_histories", ["card_expenses_id"], name: "index_user_balance_histories_on_card_expenses_id", using: :btree
  add_index "user_balance_histories", ["card_load_id"], name: "index_user_balance_histories_on_card_load_id", using: :btree
  add_index "user_balance_histories", ["card_withdrawal_id"], name: "index_user_balance_histories_on_card_withdrawal_id", using: :btree
  add_index "user_balance_histories", ["cash_on_hand_balance_id"], name: "index_user_balance_histories_on_cash_on_hand_balance_id", using: :btree
  add_index "user_balance_histories", ["cash_on_hand_load_id"], name: "index_user_balance_histories_on_cash_on_hand_load_id", using: :btree
  add_index "user_balance_histories", ["cash_on_hand_withdrawal_id"], name: "index_user_balance_histories_on_cash_on_hand_withdrawal_id", using: :btree
  add_index "user_balance_histories", ["company_id"], name: "index_user_balance_histories_on_company_id", using: :btree
  add_index "user_balance_histories", ["finly_money_balance_id"], name: "index_user_balance_histories_on_finly_money_balance_id", using: :btree
  add_index "user_balance_histories", ["finly_money_load_id"], name: "index_user_balance_histories_on_finly_money_load_id", using: :btree
  add_index "user_balance_histories", ["finly_money_withdrawal_id"], name: "index_user_balance_histories_on_finly_money_withdrawal_id", using: :btree
  add_index "user_balance_histories", ["user_id"], name: "index_user_balance_histories_on_user_id", using: :btree

  create_table "user_group_item_mappings", force: :cascade do |t|
    t.integer  "user_id",            limit: 4
    t.integer  "user_group_item_id", limit: 4
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.boolean  "is_deleted",                   default: false
    t.integer  "user_group_id",      limit: 4
  end

  add_index "user_group_item_mappings", ["user_group_id"], name: "index_user_group_item_mappings_on_user_group_id", using: :btree
  add_index "user_group_item_mappings", ["user_group_item_id"], name: "index_user_group_item_mappings_on_user_group_item_id", using: :btree
  add_index "user_group_item_mappings", ["user_id"], name: "index_user_group_item_mappings_on_user_id", using: :btree

  create_table "user_group_items", force: :cascade do |t|
    t.string   "name",          limit: 255, null: false
    t.integer  "user_group_id", limit: 4,   null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "user_group_items", ["name"], name: "index_user_group_items_on_name", using: :btree
  add_index "user_group_items", ["user_group_id"], name: "index_user_group_items_on_user_group_id", using: :btree

  create_table "user_groups", force: :cascade do |t|
    t.string   "name",       limit: 255,                 null: false
    t.integer  "company_id", limit: 4,                   null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "is_deleted",             default: false
  end

  add_index "user_groups", ["company_id"], name: "index_user_groups_on_company_id", using: :btree
  add_index "user_groups", ["name"], name: "index_user_groups_on_name", using: :btree

  create_table "user_login_tracks", force: :cascade do |t|
    t.integer  "user_id",     limit: 4,   null: false
    t.string   "ip_address",  limit: 255
    t.string   "referrer",    limit: 255
    t.string   "application", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "user_login_tracks", ["user_id"], name: "index_user_login_tracks_on_user_id", using: :btree

  create_table "user_manager_mappings", force: :cascade do |t|
    t.integer  "user_id",                limit: 4
    t.integer  "manager_id",             limit: 4
    t.integer  "finance_manager_id",     limit: 4
    t.integer  "approves_to_id",         limit: 4
    t.integer  "approves_finance_to_id", limit: 4
    t.integer  "greater_than_amount_id", limit: 4
    t.boolean  "default",                          default: false, null: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "policy_id",              limit: 4,                 null: false
  end

  add_index "user_manager_mappings", ["approves_finance_to_id"], name: "index_user_manager_mappings_on_approves_finance_to_id", using: :btree
  add_index "user_manager_mappings", ["approves_to_id"], name: "index_user_manager_mappings_on_approves_to_id", using: :btree
  add_index "user_manager_mappings", ["finance_manager_id"], name: "index_user_manager_mappings_on_finance_manager_id", using: :btree
  add_index "user_manager_mappings", ["greater_than_amount_id"], name: "index_user_manager_mappings_on_greater_than_amount_id", using: :btree
  add_index "user_manager_mappings", ["manager_id"], name: "index_user_manager_mappings_on_manager_id", using: :btree
  add_index "user_manager_mappings", ["policy_id"], name: "index_user_manager_mappings_on_policy_id", using: :btree
  add_index "user_manager_mappings", ["user_id"], name: "index_user_manager_mappings_on_user_id", using: :btree

  create_table "user_panel_subscriptions", force: :cascade do |t|
    t.integer  "user_id",                   limit: 4
    t.boolean  "disburse"
    t.boolean  "expense_management"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "yes_bank_account_transfer"
  end

  add_index "user_panel_subscriptions", ["user_id"], name: "index_user_panel_subscriptions_on_user_id", using: :btree

  create_table "user_profiles", force: :cascade do |t|
    t.integer  "user_id",             limit: 4
    t.string   "avatar_file_name",    limit: 255
    t.string   "avatar_content_type", limit: 255
    t.integer  "avatar_file_size",    limit: 4
    t.datetime "avatar_updated_at"
    t.boolean  "kyc_verified"
    t.string   "gcm_sender_id",       limit: 255
    t.string   "employee_id",         limit: 255
    t.string   "payroll_id",          limit: 255
    t.integer  "default_currency_id", limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.date     "date_of_birth"
    t.string   "gender",              limit: 255, null: false
    t.string   "address_1",           limit: 255
    t.string   "address_2",           limit: 255
    t.string   "city",                limit: 255
    t.integer  "state_id",            limit: 4
    t.string   "pin_code",            limit: 255
  end

  add_index "user_profiles", ["default_currency_id"], name: "index_user_profiles_on_default_currency_id", using: :btree
  add_index "user_profiles", ["state_id"], name: "fk_rails_9207fd1f96", using: :btree
  add_index "user_profiles", ["user_id"], name: "index_user_profiles_on_user_id", using: :btree

  create_table "user_role_mappings", force: :cascade do |t|
    t.integer  "user_id",      limit: 4, null: false
    t.integer  "user_role_id", limit: 4, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "user_role_mappings", ["user_id"], name: "index_user_role_mappings_on_user_id", using: :btree
  add_index "user_role_mappings", ["user_role_id"], name: "index_user_role_mappings_on_user_role_id", using: :btree

  create_table "user_roles", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "user_tags", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "name",       limit: 255,                null: false
    t.boolean  "active",                 default: true, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "user_tags", ["user_id"], name: "index_user_tags_on_user_id", using: :btree

  create_table "user_team_group_item_mappings", force: :cascade do |t|
    t.integer  "user_group_id",      limit: 4, null: false
    t.integer  "user_group_item_id", limit: 4, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "user_team_id",       limit: 4
  end

  add_index "user_team_group_item_mappings", ["user_group_id"], name: "index_user_team_group_item_mappings_on_user_group_id", using: :btree
  add_index "user_team_group_item_mappings", ["user_group_item_id"], name: "index_user_team_group_item_mappings_on_user_group_item_id", using: :btree
  add_index "user_team_group_item_mappings", ["user_team_id"], name: "index_user_team_group_item_mappings_on_user_team_id", using: :btree

  create_table "user_teams", force: :cascade do |t|
    t.integer  "company_id", limit: 4,   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "name",       limit: 255, null: false
  end

  add_index "user_teams", ["company_id"], name: "index_user_teams_on_company_id", using: :btree

  create_table "user_wallet_track_actions", force: :cascade do |t|
    t.string   "CreateUserWallets", limit: 255, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "user_wallet_tracks", force: :cascade do |t|
    t.integer  "user_wallet_id",              limit: 4, null: false
    t.integer  "user_wallet_track_action_id", limit: 4, null: false
    t.integer  "amount_id",                   limit: 4, null: false
    t.integer  "action_user_id",              limit: 4, null: false
    t.integer  "balance_after_action_id",     limit: 4, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "user_wallet_tracks", ["action_user_id"], name: "index_user_wallet_tracks_on_action_user_id", using: :btree
  add_index "user_wallet_tracks", ["amount_id"], name: "index_user_wallet_tracks_on_amount_id", using: :btree
  add_index "user_wallet_tracks", ["balance_after_action_id"], name: "index_user_wallet_tracks_on_balance_after_action_id", using: :btree
  add_index "user_wallet_tracks", ["user_wallet_id"], name: "index_user_wallet_tracks_on_user_wallet_id", using: :btree
  add_index "user_wallet_tracks", ["user_wallet_track_action_id"], name: "index_user_wallet_tracks_on_user_wallet_track_action_id", using: :btree

  create_table "user_wallets", force: :cascade do |t|
    t.integer  "balance_id", limit: 4, null: false
    t.integer  "user_id",    limit: 4, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "user_wallets", ["balance_id"], name: "index_user_wallets_on_balance_id", using: :btree
  add_index "user_wallets", ["user_id"], name: "index_user_wallets_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: ""
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.integer  "failed_attempts",        limit: 4,   default: 0,     null: false
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.integer  "company_id",             limit: 4,                   null: false
    t.string   "mobile_number",          limit: 255
    t.boolean  "active",                             default: true,  null: false
    t.string   "invitation_token",       limit: 255
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit",       limit: 4
    t.integer  "invited_by_id",          limit: 4
    t.string   "invited_by_type",        limit: 255
    t.integer  "invitations_count",      limit: 4,   default: 0
    t.string   "otp",                    limit: 255
    t.datetime "otp_sent_at"
    t.datetime "otp_verified_at"
    t.boolean  "otp_verified",                       default: false, null: false
    t.integer  "otp_count",              limit: 4,   default: 0,     null: false
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.boolean  "mobile_only_invite",                 default: false
    t.string   "mothers_maiden_name",    limit: 255
    t.boolean  "verified",                           default: false
    t.integer  "otp_request_type_id",    limit: 4
    t.boolean  "default_password",                   default: false
    t.boolean  "point_of_contact",                   default: false
  end

  add_index "users", ["company_id"], name: "index_users_on_company_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "version_associations", force: :cascade do |t|
    t.integer "version_id",       limit: 4
    t.string  "foreign_key_name", limit: 255, null: false
    t.integer "foreign_key_id",   limit: 4
  end

  add_index "version_associations", ["foreign_key_name", "foreign_key_id"], name: "index_version_associations_on_foreign_key", using: :btree
  add_index "version_associations", ["version_id"], name: "index_version_associations_on_version_id", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      limit: 191,                      null: false
    t.integer  "item_id",        limit: 4,                        null: false
    t.string   "event",          limit: 255,                      null: false
    t.string   "whodunnit",      limit: 255
    t.text     "object",         limit: 4294967295
    t.datetime "created_at",                        precision: 6
    t.integer  "transaction_id", limit: 4
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  add_index "versions", ["transaction_id"], name: "index_versions_on_transaction_id", using: :btree

  create_table "whitelisted_ip_types", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "whitelisted_ips", force: :cascade do |t|
    t.string   "ip_address",             limit: 255, null: false
    t.integer  "company_id",             limit: 4,   null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "whitelisted_ip_type_id", limit: 4,   null: false
  end

  add_index "whitelisted_ips", ["company_id"], name: "index_whitelisted_ips_on_company_id", using: :btree
  add_index "whitelisted_ips", ["ip_address"], name: "index_whitelisted_ips_on_ip_address", using: :btree

  create_table "yes_bank_company_accounts", force: :cascade do |t|
    t.integer  "company_id",        limit: 4
    t.integer  "wallet_balance_id", limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "balance_id",        limit: 4
  end

  add_index "yes_bank_company_accounts", ["company_id"], name: "index_yes_bank_company_accounts_on_company_id", using: :btree

  create_table "yes_bank_vendors", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "company_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "yes_bank_vendors", ["company_id"], name: "index_yes_bank_vendors_on_company_id", using: :btree

  add_foreign_key "admin_review_workflow_levels", "admin_review_workflows"
  add_foreign_key "admin_user_role_mappings", "admin_user_roles"
  add_foreign_key "admin_user_role_mappings", "admin_users"
  add_foreign_key "agreements", "agreement_types"
  add_foreign_key "amounts", "currencies"
  add_foreign_key "authentications", "users"
  add_foreign_key "auto_submit_configs", "periods"
  add_foreign_key "auto_sync_configs", "auto_sync_config_types"
  add_foreign_key "auto_sync_configs", "companies"
  add_foreign_key "auto_sync_configs", "periods"
  add_foreign_key "balance_sheets", "users"
  add_foreign_key "bank_accounts", "yes_bank_vendors"
  add_foreign_key "bank_transactions", "amounts"
  add_foreign_key "bank_transactions", "companies"
  add_foreign_key "budget_rules", "amounts"
  add_foreign_key "budget_rules", "categories"
  add_foreign_key "budget_rules", "periods"
  add_foreign_key "budget_rules", "policies"
  add_foreign_key "budget_rules", "rule_types"
  add_foreign_key "card_assign_request_tracks", "card_assign_requests"
  add_foreign_key "card_assign_requests", "admin_review_workflows"
  add_foreign_key "card_assign_requests", "card_programs"
  add_foreign_key "card_assign_requests", "cards"
  add_foreign_key "card_assign_requests", "companies"
  add_foreign_key "card_balance_histories", "amounts"
  add_foreign_key "card_balance_histories", "cards"
  add_foreign_key "card_configurations", "card_statuses"
  add_foreign_key "card_expenses", "card_transactions"
  add_foreign_key "card_expenses", "expenses"
  add_foreign_key "card_limits", "card_restrictions"
  add_foreign_key "card_restrictions", "cards"
  add_foreign_key "card_transactions", "cards"
  add_foreign_key "card_transactions", "users"
  add_foreign_key "cards", "card_types"
  add_foreign_key "cards", "companies"
  add_foreign_key "cards", "users"
  add_foreign_key "cash_on_hands", "users"
  add_foreign_key "categories", "companies"
  add_foreign_key "company_accounts", "companies"
  add_foreign_key "company_accounts", "company_account_types"
  add_foreign_key "company_agreement_tracks", "agreements"
  add_foreign_key "company_agreement_tracks", "users"
  add_foreign_key "company_balance_histories", "companies"
  add_foreign_key "company_configurations", "companies"
  add_foreign_key "company_configurations", "contacts"
  add_foreign_key "company_funds_load_requests", "amounts"
  add_foreign_key "company_funds_load_requests", "companies"
  add_foreign_key "company_kyc_trails", "company_kycs"
  add_foreign_key "company_kycs", "companies"
  add_foreign_key "company_tags", "companies"
  add_foreign_key "custom_fields", "field_configurations"
  add_foreign_key "distance_expenses", "expenses"
  add_foreign_key "distances", "physical_units"
  add_foreign_key "email_authorizations", "users"
  add_foreign_key "expense_data_extracts", "amounts"
  add_foreign_key "expense_data_extracts", "categories"
  add_foreign_key "expense_rules", "categories"
  add_foreign_key "expense_rules", "expense_rule_types"
  add_foreign_key "expense_rules", "policies"
  add_foreign_key "expense_rules", "rule_types"
  add_foreign_key "expenses", "amounts"
  add_foreign_key "expenses", "categories"
  add_foreign_key "expenses", "expense_statuses"
  add_foreign_key "expenses", "expense_types"
  add_foreign_key "expenses", "reports"
  add_foreign_key "expenses", "users"
  add_foreign_key "export_preferences", "companies"
  add_foreign_key "export_preferences", "export_fields"
  add_foreign_key "feedbacks", "feedback_types"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "field_configurations", "companies"
  add_foreign_key "field_configurations", "field_parent_types"
  add_foreign_key "field_configurations", "field_types"
  add_foreign_key "field_drop_down_items", "field_configurations"
  add_foreign_key "finly_transactions", "amounts"
  add_foreign_key "finly_transactions", "companies"
  add_foreign_key "finly_transactions", "payment_purposes"
  add_foreign_key "finly_transactions", "payments"
  add_foreign_key "finly_transactions", "transaction_types"
  add_foreign_key "individual_kyc_tracks", "individual_kycs"
  add_foreign_key "individual_kycs", "admin_review_workflows"
  add_foreign_key "individual_kycs", "companies"
  add_foreign_key "individual_kycs", "users"
  add_foreign_key "itz_cash_company_accounts", "companies"
  add_foreign_key "itz_cash_dmt_beneficiaries", "itz_cash_dmt_senders"
  add_foreign_key "itz_cash_dmt_senders", "users"
  add_foreign_key "itz_cash_properties", "companies"
  add_foreign_key "kyc_documents", "company_kyc_document_types"
  add_foreign_key "kyc_documents", "company_kycs"
  add_foreign_key "login_agreement_mappings", "agreements"
  add_foreign_key "login_agreement_mappings", "users"
  add_foreign_key "manual_expenses", "expenses"
  add_foreign_key "mcc_category_mappings", "categories"
  add_foreign_key "money_request_comments", "expenses"
  add_foreign_key "money_request_comments", "money_requests"
  add_foreign_key "money_request_comments", "payments"
  add_foreign_key "money_request_comments", "users"
  add_foreign_key "money_request_items", "amounts"
  add_foreign_key "money_request_items", "categories"
  add_foreign_key "money_request_items", "money_requests"
  add_foreign_key "money_request_tracks", "money_request_tracking_actions"
  add_foreign_key "money_request_tracks", "money_requests"
  add_foreign_key "money_request_tracks", "payments"
  add_foreign_key "money_requests", "payment_modes"
  add_foreign_key "money_requests", "payments"
  add_foreign_key "money_requests", "policies"
  add_foreign_key "money_requests", "users"
  add_foreign_key "new_card_requests", "card_types"
  add_foreign_key "new_card_requests", "companies"
  add_foreign_key "notifications", "notification_types"
  add_foreign_key "notifications", "users"
  add_foreign_key "notifier_type_configurations", "notifier_types", column: "event_id"
  add_foreign_key "notifier_type_configurations", "users"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "payment_orders", "companies"
  add_foreign_key "payment_orders", "payment_order_statuses"
  add_foreign_key "payments", "amounts"
  add_foreign_key "payments", "payment_types"
  add_foreign_key "per_diem_expenses", "expenses"
  add_foreign_key "per_diem_expenses", "per_diems"
  add_foreign_key "policies", "companies"
  add_foreign_key "policy_configurations", "policies"
  add_foreign_key "policy_user_mappings", "policies"
  add_foreign_key "policy_user_mappings", "users"
  add_foreign_key "quickbooks_configurations", "quickbooks_payment_types"
  add_foreign_key "quickbooks_configurations", "users"
  add_foreign_key "quickbooks_finly_integrations_users", "companies"
  add_foreign_key "quickbooks_finly_integrations_users", "users"
  add_foreign_key "quickbooks_payment_types", "companies"
  add_foreign_key "receipt_email_parse_failures", "users"
  add_foreign_key "receipt_emails", "expenses"
  add_foreign_key "receipts", "receipt_emails"
  add_foreign_key "receipts", "users"
  add_foreign_key "report_comments", "expenses"
  add_foreign_key "report_comments", "report_comment_actions"
  add_foreign_key "report_comments", "reports"
  add_foreign_key "report_comments", "users"
  add_foreign_key "report_tracks", "report_statuses"
  add_foreign_key "report_tracks", "report_tracking_actions"
  add_foreign_key "report_tracks", "reports"
  add_foreign_key "reports", "policies"
  add_foreign_key "reports", "report_statuses"
  add_foreign_key "reports", "users"
  add_foreign_key "time_expenses", "expenses"
  add_foreign_key "time_objects", "physical_units"
  add_foreign_key "transcribed_expenses", "amounts"
  add_foreign_key "transcribed_expenses", "expenses"
  add_foreign_key "transcribed_expenses", "receipts"
  add_foreign_key "transcribed_expenses", "users"
  add_foreign_key "user_balance_histories", "companies"
  add_foreign_key "user_balance_histories", "users"
  add_foreign_key "user_group_item_mappings", "user_group_items"
  add_foreign_key "user_group_item_mappings", "user_groups"
  add_foreign_key "user_group_item_mappings", "users"
  add_foreign_key "user_group_items", "user_groups"
  add_foreign_key "user_groups", "companies"
  add_foreign_key "user_login_tracks", "users"
  add_foreign_key "user_manager_mappings", "policies"
  add_foreign_key "user_manager_mappings", "users"
  add_foreign_key "user_panel_subscriptions", "users"
  add_foreign_key "user_profiles", "states"
  add_foreign_key "user_profiles", "users"
  add_foreign_key "user_role_mappings", "user_roles"
  add_foreign_key "user_role_mappings", "users"
  add_foreign_key "user_tags", "users"
  add_foreign_key "user_team_group_item_mappings", "user_group_items"
  add_foreign_key "user_team_group_item_mappings", "user_groups"
  add_foreign_key "user_team_group_item_mappings", "user_teams"
  add_foreign_key "user_wallet_tracks", "amounts"
  add_foreign_key "user_wallet_tracks", "user_wallet_track_actions"
  add_foreign_key "user_wallet_tracks", "user_wallets"
  add_foreign_key "user_wallets", "users"
  add_foreign_key "users", "companies"
  add_foreign_key "whitelisted_ips", "companies"
  add_foreign_key "yes_bank_company_accounts", "companies"
  add_foreign_key "yes_bank_vendors", "companies"
end
