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

ActiveRecord::Schema.define(version: 20181011081517) do

  create_table "accounting_system_configurations", force: :cascade do |t|
    t.integer  "company_id",        limit: 4,                     null: false
    t.boolean  "enabled",                         default: false
    t.string   "accounting_system", limit: 255
    t.text     "options",           limit: 65535
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "accounting_system_configurations", ["accounting_system"], name: "index_accounting_system_configurations_on_accounting_system", using: :btree
  add_index "accounting_system_configurations", ["company_id"], name: "index_accounting_system_configurations_on_company_id", using: :btree

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

  create_table "addresses", force: :cascade do |t|
    t.text     "line_1",       limit: 65535
    t.text     "line_2",       limit: 65535
    t.text     "line_3",       limit: 65535
    t.string   "city",         limit: 255
    t.integer  "state_id",     limit: 4
    t.string   "name",         limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "pin_code",     limit: 255
    t.boolean  "default"
    t.string   "parent_type",  limit: 255
    t.integer  "parent_id",    limit: 4
    t.string   "address_name", limit: 255
    t.text     "landmark",     limit: 65535
  end

  add_index "addresses", ["state_id"], name: "fk_rails_2d87b6c11e", using: :btree

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

  create_table "admin_summary_mail_configs", force: :cascade do |t|
    t.integer  "user_id",                limit: 4,   null: false
    t.integer  "period_id",              limit: 4,   null: false
    t.integer  "starting_day_of_month",  limit: 4
    t.integer  "scheduled_day_of_month", limit: 4
    t.string   "starting_day_of_week",   limit: 255
    t.string   "scheduled_day_of_week",  limit: 255
    t.string   "scheduled_time",         limit: 255, null: false
    t.string   "application",            limit: 255, null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "admin_summary_mail_configs", ["application"], name: "index_admin_summary_mail_configs_on_application", using: :btree
  add_index "admin_summary_mail_configs", ["period_id"], name: "index_admin_summary_mail_configs_on_period_id", using: :btree
  add_index "admin_summary_mail_configs", ["scheduled_day_of_month"], name: "index_admin_summary_mail_configs_on_scheduled_day_of_month", using: :btree
  add_index "admin_summary_mail_configs", ["scheduled_day_of_week"], name: "index_admin_summary_mail_configs_on_scheduled_day_of_week", using: :btree
  add_index "admin_summary_mail_configs", ["scheduled_time"], name: "index_admin_summary_mail_configs_on_scheduled_time", using: :btree
  add_index "admin_summary_mail_configs", ["starting_day_of_month"], name: "index_admin_summary_mail_configs_on_starting_day_of_month", using: :btree
  add_index "admin_summary_mail_configs", ["starting_day_of_week"], name: "index_admin_summary_mail_configs_on_starting_day_of_week", using: :btree
  add_index "admin_summary_mail_configs", ["user_id"], name: "index_admin_summary_mail_configs_on_user_id", using: :btree

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
    t.string   "email",                     limit: 255, default: "", null: false
    t.string   "encrypted_password",        limit: 255, default: "", null: false
    t.string   "reset_password_token",      limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",             limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",        limit: 255
    t.string   "last_sign_in_ip",           limit: 255
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "first_name",                limit: 255
    t.string   "last_name",                 limit: 255
    t.string   "mobile_number",             limit: 255,              null: false
    t.string   "encrypted_master_password", limit: 255
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
    t.decimal  "MYR",                   precision: 20, scale: 5
  end

  add_index "amounts", ["currency_id"], name: "index_amounts_on_currency_id", using: :btree

  create_table "approval_routes", force: :cascade do |t|
    t.integer  "purpose_id",         limit: 4,             null: false
    t.integer  "level",              limit: 4,             null: false
    t.integer  "reviewer_id",        limit: 4,             null: false
    t.integer  "threshold",          limit: 4, default: 0, null: false
    t.integer  "created_by_user_id", limit: 4,             null: false
    t.integer  "user_id",            limit: 4
    t.integer  "policy_id",          limit: 4,             null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "approval_routes", ["created_by_user_id"], name: "index_approval_routes_on_created_by_user_id", using: :btree
  add_index "approval_routes", ["level"], name: "index_approval_routes_on_level", using: :btree
  add_index "approval_routes", ["policy_id"], name: "index_approval_routes_on_policy_id", using: :btree
  add_index "approval_routes", ["purpose_id"], name: "index_approval_routes_on_purpose_id", using: :btree
  add_index "approval_routes", ["reviewer_id"], name: "index_approval_routes_on_reviewer_id", using: :btree
  add_index "approval_routes", ["threshold"], name: "index_approval_routes_on_threshold", using: :btree
  add_index "approval_routes", ["user_id"], name: "index_approval_routes_on_user_id", using: :btree

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
    t.integer  "minimum_balance_id",   limit: 4
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.boolean  "enabled",                          default: false
    t.integer  "reloadable_id",        limit: 4
    t.string   "reloadable_type",      limit: 255
    t.integer  "threshold_balance_id", limit: 4
    t.integer  "target_balance_id",    limit: 4
    t.integer  "source_account_id",    limit: 4
    t.string   "source_account_type",  limit: 255
    t.string   "application",          limit: 255
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
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "account_owner_id",   limit: 4
    t.string   "account_owner_type", limit: 255
    t.integer  "company_id",         limit: 4
    t.boolean  "reimbursable"
    t.boolean  "default_account",                default: false
    t.boolean  "is_deleted",                     default: false
  end

  add_index "bank_accounts", ["yes_bank_vendor_id"], name: "index_bank_accounts_on_yes_bank_vendor_id", using: :btree

  create_table "bank_payment_request_comment_actions", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "bank_payment_request_comments", force: :cascade do |t|
    t.text     "content",                 limit: 65535
    t.integer  "action_id",               limit: 4
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "bank_payment_request_id", limit: 4
    t.integer  "user_id",                 limit: 4
    t.integer  "forwarded_to_user_id",    limit: 4
    t.text     "note",                    limit: 65535
    t.text     "previous_value",          limit: 65535
    t.text     "new_value",               limit: 65535
    t.text     "edited_field",            limit: 65535
    t.integer  "beneficiary_id",          limit: 4
  end

  add_index "bank_payment_request_comments", ["action_id"], name: "index_bank_payment_request_comments_on_action_id", using: :btree
  add_index "bank_payment_request_comments", ["user_id"], name: "index_bank_payment_request_comments_on_user_id", using: :btree

  create_table "bank_payment_request_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "bank_payment_request_trail_actions", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "bank_payment_request_trails", force: :cascade do |t|
    t.integer  "bank_payment_request_id", limit: 4
    t.integer  "request_status_id",       limit: 4
    t.integer  "action_user_id",          limit: 4
    t.integer  "action_user_role_id",     limit: 4
    t.integer  "modified_user_id",        limit: 4
    t.integer  "modified_user_role_id",   limit: 4
    t.integer  "action_id",               limit: 4
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "action_for_user_id",      limit: 4
    t.integer  "action_for_user_role_id", limit: 4
  end

  add_index "bank_payment_request_trails", ["action_id"], name: "index_bank_payment_request_trails_on_action_id", using: :btree
  add_index "bank_payment_request_trails", ["action_user_id"], name: "index_bank_payment_request_trails_on_action_user_id", using: :btree
  add_index "bank_payment_request_trails", ["action_user_role_id"], name: "index_bank_payment_request_trails_on_action_user_role_id", using: :btree
  add_index "bank_payment_request_trails", ["bank_payment_request_id"], name: "index_bank_payment_request_trails_on_bank_payment_request_id", using: :btree
  add_index "bank_payment_request_trails", ["modified_user_id"], name: "index_bank_payment_request_trails_on_modified_user_id", using: :btree
  add_index "bank_payment_request_trails", ["modified_user_role_id"], name: "index_bank_payment_request_trails_on_modified_user_role_id", using: :btree
  add_index "bank_payment_request_trails", ["request_status_id"], name: "index_bank_payment_request_trails_on_request_status_id", using: :btree

  create_table "bank_payment_requests", force: :cascade do |t|
    t.integer  "owner_id",                     limit: 4
    t.integer  "status_id",                    limit: 4
    t.integer  "controlling_user_id",          limit: 4
    t.integer  "payment_order_id",             limit: 4
    t.string   "name",                         limit: 255
    t.integer  "requested_amount_id",          limit: 4
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.datetime "submitted_at"
    t.integer  "controlling_user_role_id",     limit: 4
    t.text     "description",                  limit: 65535
    t.integer  "controlling_for_user_id",      limit: 4
    t.integer  "controlling_for_user_role_id", limit: 4
    t.boolean  "require_approval"
    t.boolean  "is_deleted"
    t.integer  "beneficiary_type_id",          limit: 4
    t.integer  "policy_id",                    limit: 4
    t.boolean  "payment_file_downloaded",                    default: false
    t.boolean  "auto_approved"
    t.boolean  "api_initiated",                              default: false
  end

  add_index "bank_payment_requests", ["controlling_user_id"], name: "index_bank_payment_requests_on_controlling_user_id", using: :btree
  add_index "bank_payment_requests", ["owner_id"], name: "index_bank_payment_requests_on_owner_id", using: :btree
  add_index "bank_payment_requests", ["requested_amount_id"], name: "index_bank_payment_requests_on_requested_amount_id", using: :btree
  add_index "bank_payment_requests", ["status_id"], name: "index_bank_payment_requests_on_status_id", using: :btree

  create_table "bank_transaction_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

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
    t.string   "error_sub_code",              limit: 255
    t.integer  "bank_transaction_type_id",    limit: 4
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

  create_table "bill_of_supplies", force: :cascade do |t|
    t.integer  "company_id",             limit: 4
    t.integer  "user_id",                limit: 4
    t.integer  "procurement_id",         limit: 4
    t.integer  "location_id",            limit: 4
    t.integer  "delivery_location_id",   limit: 4
    t.integer  "vendor_id",              limit: 4
    t.integer  "payment_term_id",        limit: 4
    t.integer  "procurement_term_id",    limit: 4
    t.integer  "document_status_id",     limit: 4
    t.string   "doc_number",             limit: 255
    t.boolean  "override_doc_number"
    t.string   "prefix",                 limit: 255
    t.string   "sequence_start",         limit: 255
    t.date     "date"
    t.date     "bill_date"
    t.date     "transaction_date"
    t.date     "due_date"
    t.boolean  "roundoff_total_enabled"
    t.decimal  "roundoff_amount",                    precision: 10, scale: 5
    t.integer  "transaction_amount_id",  limit: 4
    t.integer  "total_before_tax_id",    limit: 4
    t.integer  "tax_amount_id",          limit: 4
    t.integer  "total_after_tax_id",     limit: 4
    t.integer  "discount_amount_id",     limit: 4
    t.integer  "balance_amount_id",      limit: 4
    t.datetime "created_at",                                                                  null: false
    t.datetime "updated_at",                                                                  null: false
    t.boolean  "is_deleted",                                                  default: false, null: false
  end

  add_index "bill_of_supplies", ["balance_amount_id"], name: "index_bill_of_supplies_on_balance_amount_id", using: :btree
  add_index "bill_of_supplies", ["company_id"], name: "index_bill_of_supplies_on_company_id", using: :btree
  add_index "bill_of_supplies", ["delivery_location_id"], name: "index_bill_of_supplies_on_delivery_location_id", using: :btree
  add_index "bill_of_supplies", ["discount_amount_id"], name: "index_bill_of_supplies_on_discount_amount_id", using: :btree
  add_index "bill_of_supplies", ["document_status_id"], name: "index_bill_of_supplies_on_document_status_id", using: :btree
  add_index "bill_of_supplies", ["location_id"], name: "index_bill_of_supplies_on_location_id", using: :btree
  add_index "bill_of_supplies", ["payment_term_id"], name: "index_bill_of_supplies_on_payment_term_id", using: :btree
  add_index "bill_of_supplies", ["procurement_id"], name: "index_bill_of_supplies_on_procurement_id", using: :btree
  add_index "bill_of_supplies", ["procurement_term_id"], name: "index_bill_of_supplies_on_procurement_term_id", using: :btree
  add_index "bill_of_supplies", ["tax_amount_id"], name: "index_bill_of_supplies_on_tax_amount_id", using: :btree
  add_index "bill_of_supplies", ["total_after_tax_id"], name: "index_bill_of_supplies_on_total_after_tax_id", using: :btree
  add_index "bill_of_supplies", ["total_before_tax_id"], name: "index_bill_of_supplies_on_total_before_tax_id", using: :btree
  add_index "bill_of_supplies", ["transaction_amount_id"], name: "index_bill_of_supplies_on_transaction_amount_id", using: :btree
  add_index "bill_of_supplies", ["user_id"], name: "index_bill_of_supplies_on_user_id", using: :btree
  add_index "bill_of_supplies", ["vendor_id"], name: "index_bill_of_supplies_on_vendor_id", using: :btree

  create_table "booking_attachments", force: :cascade do |t|
    t.string   "attachment_file_name",    limit: 255
    t.string   "attachment_content_type", limit: 255
    t.integer  "attachment_file_size",    limit: 4
    t.datetime "attachment_updated_at"
    t.integer  "booking_id",              limit: 4
    t.integer  "user_id",                 limit: 4
    t.integer  "company_id",              limit: 4
    t.text     "description",             limit: 65535
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "booking_attachments", ["booking_id"], name: "index_booking_attachments_on_booking_id", using: :btree
  add_index "booking_attachments", ["company_id"], name: "index_booking_attachments_on_company_id", using: :btree
  add_index "booking_attachments", ["user_id"], name: "index_booking_attachments_on_user_id", using: :btree

  create_table "booking_buses", force: :cascade do |t|
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "parent_id",      limit: 4
    t.string   "parent_type",    limit: 255
    t.string   "booking_class",  limit: 255
    t.integer  "from_id",        limit: 4,                     null: false
    t.integer  "to_id",          limit: 4,                     null: false
    t.integer  "cost_id",        limit: 4
    t.text     "boarding_point", limit: 65535
    t.text     "drop_point",     limit: 65535
    t.text     "description",    limit: 65535
    t.boolean  "is_deleted",                   default: false
    t.date     "departure_date"
    t.time     "departure_time"
    t.date     "arrival_date"
    t.time     "arrival_time"
    t.integer  "booking_id",     limit: 4
  end

  add_index "booking_buses", ["parent_type", "parent_id"], name: "index_booking_buses_on_parent_type_and_parent_id", using: :btree

  create_table "booking_car_rentals", force: :cascade do |t|
    t.text     "pickup_address",  limit: 65535
    t.string   "car_type",        limit: 255
    t.string   "car_number",      limit: 255
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "parent_id",       limit: 4
    t.string   "parent_type",     limit: 255
    t.integer  "pickup_city_id",  limit: 4,                     null: false
    t.integer  "drop_city_id",    limit: 4,                     null: false
    t.text     "drop_address",    limit: 65535
    t.datetime "pickup_datetime"
    t.datetime "drop_datetime"
    t.string   "rental_company",  limit: 255
    t.text     "description",     limit: 65535
    t.integer  "cost_id",         limit: 4
    t.date     "pickup_date"
    t.time     "pickup_time"
    t.date     "drop_date"
    t.time     "drop_time"
    t.boolean  "is_deleted",                    default: false
    t.integer  "booking_id",      limit: 4
  end

  add_index "booking_car_rentals", ["parent_type", "parent_id"], name: "index_booking_car_rentals_on_parent_type_and_parent_id", using: :btree

  create_table "booking_flight_classes", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "booking_flight_classes", ["name"], name: "index_booking_flight_classes_on_name", using: :btree

  create_table "booking_flights", force: :cascade do |t|
    t.string   "pnr",              limit: 255
    t.string   "airline",          limit: 255
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "parent_id",        limit: 4
    t.string   "parent_type",      limit: 255
    t.string   "stops",            limit: 255
    t.string   "ticket_number",    limit: 255
    t.integer  "from_id",          limit: 4,                     null: false
    t.integer  "to_id",            limit: 4,                     null: false
    t.text     "description",      limit: 65535
    t.string   "terminal",         limit: 255
    t.integer  "cost_id",          limit: 4
    t.integer  "booking_class_id", limit: 4
    t.boolean  "is_deleted",                     default: false
    t.date     "departure_date"
    t.time     "departure_time"
    t.date     "arrival_date"
    t.time     "arrival_time"
    t.integer  "booking_id",       limit: 4
  end

  add_index "booking_flights", ["parent_type", "parent_id"], name: "index_booking_flights_on_parent_type_and_parent_id", using: :btree

  create_table "booking_hotels", force: :cascade do |t|
    t.string   "hotel_name",       limit: 255
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "parent_id",        limit: 4
    t.string   "parent_type",      limit: 255
    t.integer  "location_id",      limit: 4,                     null: false
    t.text     "description",      limit: 65535
    t.text     "hotel_address",    limit: 65535
    t.integer  "number_of_guests", limit: 4
    t.integer  "cost_id",          limit: 4
    t.boolean  "is_deleted",                     default: false
    t.date     "checkin_date"
    t.time     "checkin_time"
    t.date     "checkout_date"
    t.time     "checkout_time"
    t.integer  "booking_id",       limit: 4
  end

  add_index "booking_hotels", ["parent_type", "parent_id"], name: "index_booking_hotels_on_parent_type_and_parent_id", using: :btree

  create_table "booking_others", force: :cascade do |t|
    t.integer  "parent_id",       limit: 4
    t.string   "parent_type",     limit: 255
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.text     "booking_details", limit: 65535
    t.text     "description",     limit: 65535
    t.integer  "cost_id",         limit: 4
    t.boolean  "is_deleted",                    default: false
    t.integer  "booking_id",      limit: 4
  end

  add_index "booking_others", ["parent_type", "parent_id"], name: "index_booking_others_on_parent_type_and_parent_id", using: :btree

  create_table "booking_requests", force: :cascade do |t|
    t.integer  "booking_status_id",             limit: 4
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.integer  "travel_request_destination_id", limit: 4
    t.integer  "booking_type_id",               limit: 4
    t.text     "note",                          limit: 65535
    t.boolean  "is_deleted",                                  default: false
    t.integer  "travel_request_id",             limit: 4,                     null: false
  end

  add_index "booking_requests", ["booking_status_id"], name: "index_booking_requests_on_booking_status_id", using: :btree
  add_index "booking_requests", ["booking_type_id"], name: "index_booking_requests_on_booking_type_id", using: :btree

  create_table "booking_restaurants", force: :cascade do |t|
    t.string   "restaurant_name",    limit: 255
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "parent_id",          limit: 4
    t.string   "parent_type",        limit: 255
    t.integer  "location_id",        limit: 4,                     null: false
    t.text     "restaurant_address", limit: 65535
    t.integer  "number_of_guests",   limit: 4
    t.text     "description",        limit: 65535
    t.boolean  "is_deleted",                       default: false
    t.date     "reservation_date"
    t.time     "reservation_time"
    t.integer  "booking_id",         limit: 4
  end

  add_index "booking_restaurants", ["parent_type", "parent_id"], name: "index_booking_restaurants_on_parent_type_and_parent_id", using: :btree

  create_table "booking_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "booking_trains", force: :cascade do |t|
    t.string   "train_number",        limit: 255
    t.string   "pnr",                 limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "parent_id",           limit: 4
    t.string   "parent_type",         limit: 255
    t.string   "booking_class",       limit: 255
    t.integer  "from_id",             limit: 4,                   null: false
    t.string   "boarding_station",    limit: 255
    t.integer  "to_id",               limit: 4,                   null: false
    t.string   "destination_station", limit: 255
    t.string   "description",         limit: 255
    t.string   "seat_number",         limit: 255
    t.integer  "cost_id",             limit: 4
    t.boolean  "is_deleted",                      default: false
    t.date     "departure_date"
    t.time     "departure_time"
    t.date     "arrival_date"
    t.time     "arrival_time"
    t.integer  "booking_id",          limit: 4
  end

  add_index "booking_trains", ["parent_type", "parent_id"], name: "index_booking_trains_on_parent_type_and_parent_id", using: :btree

  create_table "booking_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "bookings", force: :cascade do |t|
    t.integer  "booking_request_id", limit: 4
    t.integer  "booking_status_id",  limit: 4
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "booking_type_id",    limit: 4
    t.text     "note",               limit: 65535
    t.integer  "created_by_user_id", limit: 4
    t.integer  "travel_request_id",  limit: 4,     null: false
    t.integer  "destination_id",     limit: 4,     null: false
    t.integer  "parent_booking_id",  limit: 4
    t.text     "reject_reason",      limit: 65535
  end

  add_index "bookings", ["booking_request_id"], name: "index_bookings_on_booking_request_id", using: :btree
  add_index "bookings", ["booking_status_id"], name: "index_bookings_on_booking_status_id", using: :btree
  add_index "bookings", ["booking_type_id"], name: "index_bookings_on_booking_type_id", using: :btree

  create_table "branch_locations", force: :cascade do |t|
    t.string   "name",                  limit: 255
    t.string   "gstin",                 limit: 255
    t.string   "pan",                   limit: 255
    t.integer  "company_id",            limit: 4
    t.string   "address_1",             limit: 255
    t.string   "address_2",             limit: 255
    t.string   "city",                  limit: 255
    t.integer  "state_id",              limit: 4
    t.string   "country",               limit: 255
    t.string   "pin",                   limit: 255
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "contact_name",          limit: 255
    t.string   "contact_mobile_number", limit: 255
    t.boolean  "is_deleted",                        default: false, null: false
  end

  add_index "branch_locations", ["company_id"], name: "index_branch_locations_on_company_id", using: :btree
  add_index "branch_locations", ["state_id"], name: "index_branch_locations_on_state_id", using: :btree

  create_table "budget_criteria_mappings", force: :cascade do |t|
    t.integer  "budget_id",       limit: 4
    t.integer  "budgetable_id",   limit: 4
    t.string   "budgetable_type", limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "budget_criteria_mappings", ["budget_id"], name: "index_budget_criteria_mappings_on_budget_id", using: :btree

  create_table "budget_rule_category_mappings", force: :cascade do |t|
    t.integer  "budget_rule_id", limit: 4, null: false
    t.integer  "category_id",    limit: 4, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "budget_rule_category_mappings", ["budget_rule_id"], name: "index_budget_rule_category_mappings_on_budget_rule_id", using: :btree
  add_index "budget_rule_category_mappings", ["category_id"], name: "index_budget_rule_category_mappings_on_category_id", using: :btree

  create_table "budget_rule_field_mappings", force: :cascade do |t|
    t.integer  "budget_rule_id",          limit: 4, null: false
    t.integer  "field_configuration_id",  limit: 4, null: false
    t.integer  "field_drop_down_item_id", limit: 4, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "budget_rule_field_mappings", ["budget_rule_id"], name: "index_budget_rule_field_mappings_on_budget_rule_id", using: :btree
  add_index "budget_rule_field_mappings", ["field_configuration_id"], name: "index_budget_rule_field_mappings_on_field_configuration_id", using: :btree
  add_index "budget_rule_field_mappings", ["field_drop_down_item_id"], name: "index_budget_rule_field_mappings_on_field_drop_down_item_id", using: :btree

  create_table "budget_rules", force: :cascade do |t|
    t.integer  "category_id",               limit: 4
    t.integer  "amount_id",                 limit: 4
    t.integer  "period_id",                 limit: 4
    t.integer  "policy_id",                 limit: 4
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "rule_type_id",              limit: 4
    t.boolean  "include_reimbursable",                default: true
    t.boolean  "is_deleted",                          default: false
    t.integer  "expense_type_id",           limit: 4
    t.integer  "with_receipt_amount_id",    limit: 4
    t.integer  "without_receipt_amount_id", limit: 4
  end

  add_index "budget_rules", ["amount_id"], name: "index_budget_rules_on_amount_id", using: :btree
  add_index "budget_rules", ["category_id"], name: "index_budget_rules_on_category_id", using: :btree
  add_index "budget_rules", ["period_id"], name: "index_budget_rules_on_period_id", using: :btree
  add_index "budget_rules", ["policy_id"], name: "index_budget_rules_on_policy_id", using: :btree
  add_index "budget_rules", ["rule_type_id"], name: "index_budget_rules_on_rule_type_id", using: :btree

  create_table "budget_trails", force: :cascade do |t|
    t.integer  "entity_id",         limit: 4
    t.string   "entity_type",       limit: 255
    t.integer  "category_id",       limit: 4
    t.integer  "cost_center_id",    limit: 4
    t.integer  "location_id",       limit: 4
    t.integer  "vendor_id",         limit: 4
    t.integer  "amount_id",         limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "user_id",           limit: 4
    t.integer  "department_id",     limit: 4
    t.date     "date"
    t.integer  "sub_department_id", limit: 4
  end

  create_table "budgets", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.integer  "period_id",        limit: 4
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "budget_amount_id", limit: 4
    t.integer  "spent_amount_id",  limit: 4
    t.integer  "budgetable_id",    limit: 4
    t.string   "budgetable_type",  limit: 255
    t.boolean  "is_deleted",                   default: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "user_id",          limit: 4
    t.integer  "company_id",       limit: 4
    t.boolean  "purchase_order"
    t.boolean  "payment"
    t.boolean  "expense"
    t.string   "ancestry",         limit: 255
  end

  add_index "budgets", ["budget_amount_id"], name: "index_budgets_on_budget_amount_id", using: :btree
  add_index "budgets", ["budgetable_type", "budgetable_id"], name: "index_budgets_on_budgetable_type_and_budgetable_id", using: :btree
  add_index "budgets", ["company_id"], name: "index_budgets_on_company_id", using: :btree
  add_index "budgets", ["period_id"], name: "index_budgets_on_period_id", using: :btree
  add_index "budgets", ["spent_amount_id"], name: "index_budgets_on_spent_amount_id", using: :btree
  add_index "budgets", ["user_id"], name: "index_budgets_on_user_id", using: :btree

  create_table "callback_tracks", force: :cascade do |t|
    t.integer  "company_id",  limit: 4
    t.text     "request",     limit: 65535
    t.text     "response",    limit: 16777215
    t.integer  "entity_id",   limit: 4
    t.string   "entity_type", limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "success"
  end

  add_index "callback_tracks", ["company_id"], name: "index_callback_tracks_on_company_id", using: :btree

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
    t.string   "card_processor_status",    limit: 255
    t.integer  "replaced_card_id",         limit: 4
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
    t.integer  "company_id",                 limit: 4,                  null: false
    t.string   "name",                       limit: 255,                null: false
    t.string   "gl_code",                    limit: 255
    t.string   "payroll_code",               limit: 255
    t.boolean  "active",                                 default: true, null: false
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.integer  "purpose_id",                 limit: 4
    t.boolean  "expense_management"
    t.boolean  "vendor_payments"
    t.boolean  "outward_invoices"
    t.boolean  "inward_invoice_line_items"
    t.string   "ancestry",                   limit: 255
    t.boolean  "outward_invoice_line_items"
  end

  add_index "categories", ["ancestry"], name: "index_categories_on_ancestry", using: :btree
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

  create_table "collect_company_details", force: :cascade do |t|
    t.string   "gst",                       limit: 255
    t.string   "pan",                       limit: 255
    t.integer  "company_id",                limit: 4
    t.string   "company_logo_file_name",    limit: 255
    t.string   "company_logo_content_type", limit: 255
    t.integer  "company_logo_file_size",    limit: 4
    t.datetime "company_logo_updated_at"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.text     "address",                   limit: 65535
    t.text     "pin",                       limit: 65535
  end

  add_index "collect_company_details", ["company_id"], name: "index_collect_company_details_on_company_id", using: :btree

  create_table "collect_transaction_purposes", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "collect_transaction_virtual_account_mappings", force: :cascade do |t|
    t.integer  "virtual_account_id",     limit: 4
    t.integer  "transaction_purpose_id", limit: 4
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "companies", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "active",                       default: true, null: false
    t.integer  "base_currency_id", limit: 4,   default: 1
    t.integer  "status_id",        limit: 4,   default: 1,    null: false
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

  create_table "company_branches", force: :cascade do |t|
    t.integer  "collect_company_detail_id", limit: 4
    t.string   "name",                      limit: 255
    t.string   "pan",                       limit: 255
    t.string   "gst",                       limit: 255
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "company_id",                limit: 4
    t.string   "address_1",                 limit: 255
    t.string   "address_2",                 limit: 255
    t.string   "city",                      limit: 255
    t.integer  "state_id",                  limit: 4
    t.string   "country",                   limit: 255
    t.string   "pin",                       limit: 255
  end

  add_index "company_branches", ["collect_company_detail_id"], name: "index_company_branches_on_collect_company_detail_id", using: :btree
  add_index "company_branches", ["company_id"], name: "index_company_branches_on_company_id", using: :btree

  create_table "company_configurations", force: :cascade do |t|
    t.integer  "company_id",                       limit: 4,                     null: false
    t.integer  "contact_id",                       limit: 4
    t.boolean  "verified",                                       default: false
    t.string   "logo_file_name",                   limit: 255
    t.string   "logo_content_type",                limit: 255
    t.integer  "logo_file_size",                   limit: 4
    t.datetime "logo_updated_at"
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.boolean  "other_expense_types",                            default: false
    t.text     "encrypted_easy_login_params",      limit: 65535
    t.string   "registered_mobile_number",         limit: 255
    t.string   "bank_type",                        limit: 255
    t.integer  "default_card_expense_category_id", limit: 4
    t.boolean  "darwinbox_sso_enabled",                          default: false
  end

  add_index "company_configurations", ["company_id"], name: "index_company_configurations_on_company_id", using: :btree
  add_index "company_configurations", ["contact_id"], name: "index_company_configurations_on_contact_id", using: :btree

  create_table "company_departments", force: :cascade do |t|
    t.string   "name",               limit: 255,                 null: false
    t.integer  "company_id",         limit: 4,                   null: false
    t.boolean  "active",                         default: true
    t.boolean  "is_deleted",                     default: false
    t.integer  "created_by_user_id", limit: 4,                   null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "company_departments", ["active"], name: "index_company_departments_on_active", using: :btree
  add_index "company_departments", ["company_id"], name: "index_company_departments_on_company_id", using: :btree
  add_index "company_departments", ["created_by_user_id"], name: "index_company_departments_on_created_by_user_id", using: :btree
  add_index "company_departments", ["is_deleted"], name: "index_company_departments_on_is_deleted", using: :btree
  add_index "company_departments", ["name"], name: "index_company_departments_on_name", using: :btree

  create_table "company_funds_auto_transfer_configs", force: :cascade do |t|
    t.integer  "company_id",           limit: 4
    t.integer  "threshold_amount_id",  limit: 4
    t.string   "frequency_name",       limit: 255
    t.string   "frequency_day",        limit: 255
    t.string   "amount_transfer_type", limit: 255
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.boolean  "enabled",                          default: false
    t.string   "transfer_mode",        limit: 255
  end

  add_index "company_funds_auto_transfer_configs", ["company_id"], name: "index_company_funds_auto_transfer_configs_on_company_id", using: :btree
  add_index "company_funds_auto_transfer_configs", ["threshold_amount_id"], name: "index_company_funds_auto_transfer_configs_on_threshold_amount_id", using: :btree

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

  create_table "company_location_departments", force: :cascade do |t|
    t.integer  "branch_location_id",    limit: 4, null: false
    t.integer  "company_department_id", limit: 4, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "company_location_departments", ["branch_location_id"], name: "index_company_location_departments_on_branch_location_id", using: :btree
  add_index "company_location_departments", ["company_department_id"], name: "index_company_location_departments_on_company_department_id", using: :btree

  create_table "company_pocket_templates", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.integer  "company_id",          limit: 4
    t.integer  "user_pocket_type_id", limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "company_pocket_templates", ["company_id"], name: "index_company_pocket_templates_on_company_id", using: :btree
  add_index "company_pocket_templates", ["user_pocket_type_id"], name: "index_company_pocket_templates_on_user_pocket_type_id", using: :btree

  create_table "company_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "company_statuses", ["name"], name: "index_company_statuses_on_name", using: :btree

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

  create_table "cost_centers", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "application", limit: 255
    t.integer  "company_id",  limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.boolean  "is_deleted"
  end

  add_index "cost_centers", ["company_id"], name: "index_cost_centers_on_company_id", using: :btree

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
    t.decimal  "INR",        precision: 20, scale: 5
    t.decimal  "USD",        precision: 20, scale: 5
    t.decimal  "GBP",        precision: 20, scale: 5
    t.decimal  "EUR",        precision: 20, scale: 5
    t.decimal  "CAD",        precision: 20, scale: 5
    t.decimal  "HRK",        precision: 20, scale: 5
    t.decimal  "RUB",        precision: 20, scale: 5
    t.decimal  "BGN",        precision: 20, scale: 5
    t.decimal  "BRL",        precision: 20, scale: 5
    t.decimal  "CHF",        precision: 20, scale: 5
    t.decimal  "CNY",        precision: 20, scale: 5
    t.decimal  "CZK",        precision: 20, scale: 5
    t.decimal  "DKK",        precision: 20, scale: 5
    t.decimal  "HKD",        precision: 20, scale: 5
    t.decimal  "HUF",        precision: 20, scale: 5
    t.decimal  "IDR",        precision: 20, scale: 5
    t.decimal  "ILS",        precision: 20, scale: 5
    t.decimal  "JPY",        precision: 20, scale: 5
    t.decimal  "KRW",        precision: 20, scale: 5
    t.decimal  "MXN",        precision: 20, scale: 5
    t.decimal  "MYR",        precision: 20, scale: 5
    t.decimal  "NOK",        precision: 20, scale: 5
    t.decimal  "NZD",        precision: 20, scale: 5
    t.decimal  "PHP",        precision: 20, scale: 5
    t.decimal  "PLN",        precision: 20, scale: 5
    t.decimal  "RON",        precision: 20, scale: 5
    t.decimal  "SEK",        precision: 20, scale: 5
    t.decimal  "SGD",        precision: 20, scale: 5
    t.decimal  "THB",        precision: 20, scale: 5
    t.decimal  "TRY",        precision: 20, scale: 5
    t.decimal  "ZAR",        precision: 20, scale: 5
    t.decimal  "AUD",        precision: 20, scale: 5
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.decimal  "AED",        precision: 20, scale: 5
    t.decimal  "AFN",        precision: 20, scale: 5
    t.decimal  "ALL",        precision: 20, scale: 5
    t.decimal  "AMD",        precision: 20, scale: 5
    t.decimal  "ANG",        precision: 20, scale: 5
    t.decimal  "AOA",        precision: 20, scale: 5
    t.decimal  "ARS",        precision: 20, scale: 5
    t.decimal  "AWG",        precision: 20, scale: 5
    t.decimal  "AZN",        precision: 20, scale: 5
    t.decimal  "BAM",        precision: 20, scale: 5
    t.decimal  "BBD",        precision: 20, scale: 5
    t.decimal  "BDT",        precision: 20, scale: 5
    t.decimal  "BHD",        precision: 20, scale: 5
    t.decimal  "BIF",        precision: 20, scale: 5
    t.decimal  "BMD",        precision: 20, scale: 5
    t.decimal  "BND",        precision: 20, scale: 5
    t.decimal  "BOB",        precision: 20, scale: 5
    t.decimal  "BSD",        precision: 20, scale: 5
    t.decimal  "BTC",        precision: 20, scale: 5
    t.decimal  "BTN",        precision: 20, scale: 5
    t.decimal  "BWP",        precision: 20, scale: 5
    t.decimal  "BYN",        precision: 20, scale: 5
    t.decimal  "BYR",        precision: 20, scale: 5
    t.decimal  "BZD",        precision: 20, scale: 5
    t.decimal  "CDF",        precision: 20, scale: 5
    t.decimal  "CLF",        precision: 20, scale: 5
    t.decimal  "CLP",        precision: 20, scale: 5
    t.decimal  "COP",        precision: 20, scale: 5
    t.decimal  "CRC",        precision: 20, scale: 5
    t.decimal  "CUC",        precision: 20, scale: 5
    t.decimal  "CUP",        precision: 20, scale: 5
    t.decimal  "CVE",        precision: 20, scale: 5
    t.decimal  "DJF",        precision: 20, scale: 5
    t.decimal  "DOP",        precision: 20, scale: 5
    t.decimal  "DZD",        precision: 20, scale: 5
    t.decimal  "EEK",        precision: 10, scale: 5
    t.decimal  "EGP",        precision: 20, scale: 5
    t.decimal  "ERN",        precision: 20, scale: 5
    t.decimal  "ETB",        precision: 20, scale: 5
    t.decimal  "FJD",        precision: 20, scale: 5
    t.decimal  "FKP",        precision: 20, scale: 5
    t.decimal  "GEL",        precision: 20, scale: 5
    t.decimal  "GGP",        precision: 20, scale: 5
    t.decimal  "GHS",        precision: 20, scale: 5
    t.decimal  "GIP",        precision: 20, scale: 5
    t.decimal  "GMD",        precision: 20, scale: 5
    t.decimal  "GNF",        precision: 20, scale: 5
    t.decimal  "GTQ",        precision: 20, scale: 5
    t.decimal  "GYD",        precision: 20, scale: 5
    t.decimal  "HNL",        precision: 20, scale: 5
    t.decimal  "HTG",        precision: 20, scale: 5
    t.decimal  "IMP",        precision: 20, scale: 5
    t.decimal  "IQD",        precision: 20, scale: 5
    t.decimal  "IRR",        precision: 20, scale: 5
    t.decimal  "ISK",        precision: 20, scale: 5
    t.decimal  "JEP",        precision: 20, scale: 5
    t.decimal  "JMD",        precision: 20, scale: 5
    t.decimal  "JOD",        precision: 20, scale: 5
    t.decimal  "KES",        precision: 20, scale: 5
    t.decimal  "KGS",        precision: 20, scale: 5
    t.decimal  "KHR",        precision: 20, scale: 5
    t.decimal  "KMF",        precision: 20, scale: 5
    t.decimal  "KPW",        precision: 20, scale: 5
    t.decimal  "KWD",        precision: 20, scale: 5
    t.decimal  "KYD",        precision: 20, scale: 5
    t.decimal  "KZT",        precision: 20, scale: 5
    t.decimal  "LAK",        precision: 20, scale: 5
    t.decimal  "LBP",        precision: 20, scale: 5
    t.decimal  "LKR",        precision: 20, scale: 5
    t.decimal  "LRD",        precision: 20, scale: 5
    t.decimal  "LSL",        precision: 20, scale: 5
    t.decimal  "LTL",        precision: 20, scale: 5
    t.decimal  "LVL",        precision: 20, scale: 5
    t.decimal  "LYD",        precision: 20, scale: 5
    t.decimal  "MAD",        precision: 20, scale: 5
    t.decimal  "MDL",        precision: 20, scale: 5
    t.decimal  "MGA",        precision: 20, scale: 5
    t.decimal  "MKD",        precision: 20, scale: 5
    t.decimal  "MMK",        precision: 20, scale: 5
    t.decimal  "MNT",        precision: 20, scale: 5
    t.decimal  "MOP",        precision: 20, scale: 5
    t.decimal  "MRO",        precision: 20, scale: 5
    t.decimal  "MUR",        precision: 20, scale: 5
    t.decimal  "MVR",        precision: 20, scale: 5
    t.decimal  "MWK",        precision: 20, scale: 5
    t.decimal  "MZN",        precision: 20, scale: 5
    t.decimal  "NAD",        precision: 20, scale: 5
    t.decimal  "NGN",        precision: 20, scale: 5
    t.decimal  "NIO",        precision: 20, scale: 5
    t.decimal  "NPR",        precision: 20, scale: 5
    t.decimal  "OMR",        precision: 20, scale: 5
    t.decimal  "PAB",        precision: 20, scale: 5
    t.decimal  "PEN",        precision: 20, scale: 5
    t.decimal  "PGK",        precision: 20, scale: 5
    t.decimal  "PKR",        precision: 20, scale: 5
    t.decimal  "PYG",        precision: 20, scale: 5
    t.decimal  "QAR",        precision: 20, scale: 5
    t.decimal  "RSD",        precision: 20, scale: 5
    t.decimal  "RWF",        precision: 20, scale: 5
    t.decimal  "SAR",        precision: 20, scale: 5
    t.decimal  "SBD",        precision: 20, scale: 5
    t.decimal  "SCR",        precision: 20, scale: 5
    t.decimal  "SDG",        precision: 20, scale: 5
    t.decimal  "SHP",        precision: 20, scale: 5
    t.decimal  "SLL",        precision: 20, scale: 5
    t.decimal  "SOS",        precision: 20, scale: 5
    t.decimal  "SRD",        precision: 20, scale: 5
    t.decimal  "STD",        precision: 20, scale: 5
    t.decimal  "SVC",        precision: 20, scale: 5
    t.decimal  "SYP",        precision: 20, scale: 5
    t.decimal  "SZL",        precision: 20, scale: 5
    t.decimal  "TJS",        precision: 20, scale: 5
    t.decimal  "TMT",        precision: 20, scale: 5
    t.decimal  "TND",        precision: 20, scale: 5
    t.decimal  "TOP",        precision: 20, scale: 5
    t.decimal  "TTD",        precision: 20, scale: 5
    t.decimal  "TWD",        precision: 20, scale: 5
    t.decimal  "TZS",        precision: 20, scale: 5
    t.decimal  "UAH",        precision: 20, scale: 5
    t.decimal  "UGX",        precision: 20, scale: 5
    t.decimal  "UYU",        precision: 20, scale: 5
    t.decimal  "UZS",        precision: 20, scale: 5
    t.decimal  "VEF",        precision: 20, scale: 5
    t.decimal  "VND",        precision: 20, scale: 5
    t.decimal  "VUV",        precision: 20, scale: 5
    t.decimal  "WST",        precision: 20, scale: 5
    t.decimal  "XAF",        precision: 20, scale: 5
    t.decimal  "XAG",        precision: 20, scale: 5
    t.decimal  "XAU",        precision: 20, scale: 5
    t.decimal  "XCD",        precision: 20, scale: 5
    t.decimal  "XDR",        precision: 20, scale: 5
    t.decimal  "XOF",        precision: 20, scale: 5
    t.decimal  "XPF",        precision: 20, scale: 5
    t.decimal  "YER",        precision: 20, scale: 5
    t.decimal  "ZMK",        precision: 20, scale: 5
    t.decimal  "ZMW",        precision: 20, scale: 5
    t.decimal  "ZWL",        precision: 20, scale: 5
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
    t.integer  "dependent_parent_id",    limit: 4
    t.string   "dependent_parent_type",  limit: 255
    t.string   "field_key",              limit: 255
  end

  add_index "custom_fields", ["field_configuration_id"], name: "index_custom_fields_on_field_configuration_id", using: :btree
  add_index "custom_fields", ["parent_id"], name: "index_custom_fields_on_parent_id", using: :btree
  add_index "custom_fields", ["parent_type"], name: "index_custom_fields_on_parent_type", using: :btree

  create_table "customer_account_transactions", force: :cascade do |t|
    t.integer  "customer_account_id",    limit: 4
    t.string   "transaction_type",       limit: 255
    t.integer  "transaction_amount_id",  limit: 4
    t.string   "note",                   limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "associated_object_id",   limit: 4
    t.string   "associated_object_type", limit: 255
  end

  add_index "customer_account_transactions", ["associated_object_type", "associated_object_id"], name: "indx_cstmer_acc_tranxs_on_assoc_acc_type_and_assoc_acc_id", using: :btree
  add_index "customer_account_transactions", ["customer_account_id"], name: "index_customer_account_transactions_on_customer_account_id", using: :btree
  add_index "customer_account_transactions", ["transaction_amount_id"], name: "index_customer_account_transactions_on_transaction_amount_id", using: :btree

  create_table "customer_accounts", force: :cascade do |t|
    t.integer  "customer_id", limit: 4
    t.integer  "balance_id",  limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "customer_accounts", ["balance_id"], name: "index_customer_accounts_on_balance_id", using: :btree
  add_index "customer_accounts", ["customer_id"], name: "index_customer_accounts_on_customer_id", using: :btree

  create_table "customer_attachments", force: :cascade do |t|
    t.string   "attached_file_file_name",    limit: 255
    t.string   "attached_file_content_type", limit: 255
    t.integer  "attached_file_file_size",    limit: 4
    t.datetime "attached_file_updated_at"
    t.integer  "customer_id",                limit: 4
    t.text     "note",                       limit: 65535
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "customer_attachments", ["customer_id"], name: "index_customer_attachments_on_customer_id", using: :btree

  create_table "customers", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "email",         limit: 255
    t.string   "mobile_number", limit: 255
    t.text     "description",   limit: 65535
    t.integer  "company_id",    limit: 4
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "gst",           limit: 255
    t.string   "pan",           limit: 255
    t.integer  "created_by_id", limit: 4
    t.boolean  "active",                      default: true
    t.boolean  "is_deleted",                  default: false
  end

  create_table "delivery_challans", force: :cascade do |t|
    t.integer  "company_id",             limit: 4
    t.integer  "user_id",                limit: 4
    t.integer  "procurement_id",         limit: 4
    t.integer  "location_id",            limit: 4
    t.integer  "delivery_location_id",   limit: 4
    t.integer  "vendor_id",              limit: 4
    t.integer  "payment_term_id",        limit: 4
    t.integer  "procurement_term_id",    limit: 4
    t.integer  "document_status_id",     limit: 4
    t.string   "doc_number",             limit: 255
    t.boolean  "override_doc_number"
    t.string   "prefix",                 limit: 255
    t.string   "sequence_start",         limit: 255
    t.date     "date"
    t.date     "challan_date"
    t.date     "due_date"
    t.boolean  "roundoff_total_enabled"
    t.decimal  "roundoff_amount",                    precision: 10, scale: 5
    t.integer  "transaction_amount_id",  limit: 4
    t.integer  "total_before_tax_id",    limit: 4
    t.integer  "tax_amount_id",          limit: 4
    t.integer  "total_after_tax_id",     limit: 4
    t.integer  "discount_amount_id",     limit: 4
    t.integer  "balance_amount_id",      limit: 4
    t.datetime "created_at",                                                                  null: false
    t.datetime "updated_at",                                                                  null: false
    t.boolean  "is_deleted",                                                  default: false, null: false
  end

  add_index "delivery_challans", ["balance_amount_id"], name: "index_delivery_challans_on_balance_amount_id", using: :btree
  add_index "delivery_challans", ["company_id"], name: "index_delivery_challans_on_company_id", using: :btree
  add_index "delivery_challans", ["delivery_location_id"], name: "index_delivery_challans_on_delivery_location_id", using: :btree
  add_index "delivery_challans", ["discount_amount_id"], name: "index_delivery_challans_on_discount_amount_id", using: :btree
  add_index "delivery_challans", ["document_status_id"], name: "index_delivery_challans_on_document_status_id", using: :btree
  add_index "delivery_challans", ["location_id"], name: "index_delivery_challans_on_location_id", using: :btree
  add_index "delivery_challans", ["payment_term_id"], name: "index_delivery_challans_on_payment_term_id", using: :btree
  add_index "delivery_challans", ["procurement_id"], name: "index_delivery_challans_on_procurement_id", using: :btree
  add_index "delivery_challans", ["procurement_term_id"], name: "index_delivery_challans_on_procurement_term_id", using: :btree
  add_index "delivery_challans", ["tax_amount_id"], name: "index_delivery_challans_on_tax_amount_id", using: :btree
  add_index "delivery_challans", ["total_after_tax_id"], name: "index_delivery_challans_on_total_after_tax_id", using: :btree
  add_index "delivery_challans", ["total_before_tax_id"], name: "index_delivery_challans_on_total_before_tax_id", using: :btree
  add_index "delivery_challans", ["transaction_amount_id"], name: "index_delivery_challans_on_transaction_amount_id", using: :btree
  add_index "delivery_challans", ["user_id"], name: "index_delivery_challans_on_user_id", using: :btree
  add_index "delivery_challans", ["vendor_id"], name: "index_delivery_challans_on_vendor_id", using: :btree

  create_table "departments", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.integer  "company_id",     limit: 4
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.boolean  "is_deleted",                 default: false, null: false
    t.string   "ancestry",       limit: 255
    t.integer  "cost_center_id", limit: 4
  end

  add_index "departments", ["company_id"], name: "index_departments_on_company_id", using: :btree
  add_index "departments", ["cost_center_id"], name: "index_departments_on_cost_center_id", using: :btree

  create_table "desktop_users", force: :cascade do |t|
    t.string   "email",      limit: 255, null: false
    t.string   "country",    limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "distance_expense_configs", force: :cascade do |t|
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.boolean  "enabled"
    t.integer  "default_category_id", limit: 4
    t.integer  "rate_id",             limit: 4
    t.integer  "distance_unit_id",    limit: 4
    t.integer  "policy_id",           limit: 4,                 null: false
    t.boolean  "enforce_category",              default: false
  end

  create_table "distance_expense_types", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "distance_expense_types", ["name"], name: "index_distance_expense_types_on_name", using: :btree

  create_table "distance_expenses", force: :cascade do |t|
    t.integer  "expense_id",                        limit: 4
    t.boolean  "is_deleted",                                                           default: false
    t.datetime "created_at",                                                                           null: false
    t.datetime "updated_at",                                                                           null: false
    t.integer  "distance_id",                       limit: 4
    t.integer  "maps_distance_id",                  limit: 4
    t.integer  "type_id",                           limit: 4
    t.decimal  "odometer_reading_start",                      precision: 10, scale: 2
    t.decimal  "odometer_reading_end",                        precision: 10, scale: 2
    t.integer  "odometer_reading_receipt_start_id", limit: 4
    t.integer  "odometer_reading_receipt_end_id",   limit: 4
    t.integer  "vehicle_rate_id",                   limit: 4
    t.integer  "distance_rate_id",                  limit: 4
    t.integer  "distance_unit_id",                  limit: 4
  end

  add_index "distance_expenses", ["expense_id"], name: "index_distance_expenses_on_expense_id", using: :btree

  create_table "distances", force: :cascade do |t|
    t.decimal  "value",                      precision: 10, scale: 4
    t.integer  "physical_unit_id", limit: 4
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  add_index "distances", ["physical_unit_id"], name: "index_distances_on_physical_unit_id", using: :btree

  create_table "document_items", force: :cascade do |t|
    t.integer  "parent_document_id",     limit: 4,                                          null: false
    t.string   "parent_document_type",   limit: 255,                                        null: false
    t.integer  "inventory_line_item_id", limit: 4
    t.string   "description",            limit: 255
    t.string   "hsn_sac",                limit: 255
    t.decimal  "quantity",                           precision: 20, scale: 5
    t.decimal  "rate",                               precision: 20, scale: 5
    t.decimal  "tax",                                precision: 20, scale: 5, default: 0.0
    t.decimal  "tds",                                precision: 20, scale: 5, default: 0.0
    t.decimal  "discount",                           precision: 20, scale: 5, default: 0.0
    t.integer  "tax_amount_id",          limit: 4
    t.integer  "tds_amount_id",          limit: 4
    t.integer  "discount_amount_id",     limit: 4
    t.integer  "total_amount_id",        limit: 4
    t.date     "delivery_date"
    t.string   "comment",                limit: 255
    t.datetime "created_at",                                                                null: false
    t.datetime "updated_at",                                                                null: false
    t.integer  "purchase_order_item_id", limit: 4
    t.string   "product_id",             limit: 255
  end

  add_index "document_items", ["discount_amount_id"], name: "index_document_items_on_discount_amount_id", using: :btree
  add_index "document_items", ["inventory_line_item_id"], name: "index_document_items_on_inventory_line_item_id", using: :btree
  add_index "document_items", ["parent_document_type", "parent_document_id"], name: "indx_doc_items_on_parent_doc_type_and_parent_doc_id", using: :btree
  add_index "document_items", ["purchase_order_item_id"], name: "index_document_items_on_purchase_order_item_id", using: :btree
  add_index "document_items", ["tax_amount_id"], name: "index_document_items_on_tax_amount_id", using: :btree
  add_index "document_items", ["tds_amount_id"], name: "index_document_items_on_tds_amount_id", using: :btree
  add_index "document_items", ["total_amount_id"], name: "index_document_items_on_total_amount_id", using: :btree

  create_table "document_level_reviewer_mappings", force: :cascade do |t|
    t.integer  "policy_id",                       limit: 4
    t.integer  "level_id",                        limit: 4
    t.integer  "reviewer_id",                     limit: 4
    t.integer  "document_reviewer_mappable_id",   limit: 4,   null: false
    t.string   "document_reviewer_mappable_type", limit: 255, null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "document_level_reviewer_mappings", ["document_reviewer_mappable_type", "document_reviewer_mappable_id"], name: "indx_doc_lvl_rvwr_mpng_on_doc_rvwr_mpble_tp_n_doc_rvwr_mpble_id", using: :btree
  add_index "document_level_reviewer_mappings", ["level_id"], name: "index_document_level_reviewer_mappings_on_level_id", using: :btree
  add_index "document_level_reviewer_mappings", ["policy_id"], name: "index_document_level_reviewer_mappings_on_policy_id", using: :btree
  add_index "document_level_reviewer_mappings", ["reviewer_id"], name: "index_document_level_reviewer_mappings_on_reviewer_id", using: :btree

  create_table "document_number_config_types", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "document_number_configs", force: :cascade do |t|
    t.string   "prefix",                         limit: 255
    t.string   "sequence_start",                 limit: 255
    t.integer  "company_id",                     limit: 4
    t.integer  "document_number_config_type_id", limit: 4
    t.integer  "purpose_id",                     limit: 4
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "document_number_configs", ["company_id"], name: "index_document_number_configs_on_company_id", using: :btree
  add_index "document_number_configs", ["document_number_config_type_id"], name: "index_document_number_configs_on_document_number_config_type_id", using: :btree
  add_index "document_number_configs", ["purpose_id"], name: "index_document_number_configs_on_purpose_id", using: :btree

  create_table "document_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "duplicate_expense_mappings", force: :cascade do |t|
    t.integer  "expense_id",           limit: 4, null: false
    t.integer  "duplicate_expense_id", limit: 4, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "duplicate_expense_mappings", ["expense_id"], name: "index_duplicate_expense_mappings_on_expense_id", using: :btree

  create_table "e_way_bills", force: :cascade do |t|
    t.integer  "company_id",                limit: 4
    t.integer  "user_id",                   limit: 4
    t.integer  "procurement_id",            limit: 4
    t.integer  "location_id",               limit: 4
    t.integer  "delivery_location_id",      limit: 4
    t.integer  "vendor_id",                 limit: 4
    t.integer  "payment_term_id",           limit: 4
    t.integer  "procurement_term_id",       limit: 4
    t.string   "doc_number",                limit: 255
    t.date     "date"
    t.string   "generated_by",              limit: 255
    t.datetime "valid_from"
    t.datetime "valid_to"
    t.string   "ref_doc_name",              limit: 255
    t.string   "ref_doc_date",              limit: 255
    t.integer  "amount_id",                 limit: 4
    t.string   "hsn_code",                  limit: 255
    t.string   "reason_for_transportation", limit: 255
    t.string   "mode",                      limit: 255
    t.string   "vehicle_number",            limit: 255
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.boolean  "is_deleted",                            default: false, null: false
  end

  add_index "e_way_bills", ["amount_id"], name: "index_e_way_bills_on_amount_id", using: :btree
  add_index "e_way_bills", ["company_id"], name: "index_e_way_bills_on_company_id", using: :btree
  add_index "e_way_bills", ["delivery_location_id"], name: "index_e_way_bills_on_delivery_location_id", using: :btree
  add_index "e_way_bills", ["location_id"], name: "index_e_way_bills_on_location_id", using: :btree
  add_index "e_way_bills", ["payment_term_id"], name: "index_e_way_bills_on_payment_term_id", using: :btree
  add_index "e_way_bills", ["procurement_id"], name: "index_e_way_bills_on_procurement_id", using: :btree
  add_index "e_way_bills", ["procurement_term_id"], name: "index_e_way_bills_on_procurement_term_id", using: :btree
  add_index "e_way_bills", ["user_id"], name: "index_e_way_bills_on_user_id", using: :btree
  add_index "e_way_bills", ["vendor_id"], name: "index_e_way_bills_on_vendor_id", using: :btree

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
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "rule_type_id",           limit: 4
    t.integer  "expense_rule_type_id",   limit: 4
    t.integer  "policy_id",              limit: 4
    t.boolean  "is_deleted",                       default: false
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

  create_table "expense_tax_types", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "expense_tax_types", ["name"], name: "index_expense_tax_types_on_name", using: :btree

  create_table "expense_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "expenses", force: :cascade do |t|
    t.integer  "amount_id",              limit: 4
    t.integer  "expense_status_id",      limit: 4
    t.text     "note",                   limit: 65535
    t.date     "date"
    t.integer  "user_id",                limit: 4
    t.integer  "expense_type_id",        limit: 4
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.text     "manager_memo",           limit: 65535
    t.integer  "rejecting_manager_id",   limit: 4
    t.integer  "report_id",              limit: 4
    t.integer  "category_id",            limit: 4
    t.boolean  "is_deleted",                                          default: false, null: false
    t.boolean  "transcribed",                                         default: false
    t.boolean  "personal",                                            default: false
    t.boolean  "reimbursable"
    t.boolean  "synced_with_quickbooks",                              default: false
    t.string   "split_link",             limit: 255
    t.boolean  "deleted_to_split",                                    default: false
    t.boolean  "from_cash_on_hand",                                   default: false
    t.boolean  "cash_on_hand_blocked"
    t.integer  "expense_tax_type_id",    limit: 4
    t.decimal  "gst_percentage",                       precision: 10
    t.decimal  "tds_percentage",                       precision: 10
    t.integer  "tds_amount_id",          limit: 4
    t.integer  "gst_type_id",            limit: 4
    t.integer  "tds_slab_id",            limit: 4
    t.integer  "gst_amount_id",          limit: 4
    t.datetime "usage_date_start"
    t.datetime "usage_date_end"
    t.string   "usage_date_type",        limit: 255
    t.integer  "spent_from_id",          limit: 4
    t.boolean  "custom_conversion_rate",                              default: false
  end

  add_index "expenses", ["amount_id"], name: "index_expenses_on_amount_id", using: :btree
  add_index "expenses", ["category_id"], name: "index_expenses_on_category_id", using: :btree
  add_index "expenses", ["expense_status_id"], name: "index_expenses_on_expense_status_id", using: :btree
  add_index "expenses", ["expense_tax_type_id"], name: "index_expenses_on_expense_tax_type_id", using: :btree
  add_index "expenses", ["expense_type_id"], name: "index_expenses_on_expense_type_id", using: :btree
  add_index "expenses", ["report_id"], name: "index_expenses_on_report_id", using: :btree
  add_index "expenses", ["user_id"], name: "index_expenses_on_user_id", using: :btree

  create_table "export_config_types", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "export_config_types", ["name"], name: "index_export_config_types_on_name", using: :btree

  create_table "export_configs", force: :cascade do |t|
    t.integer  "company_id",            limit: 4,                  null: false
    t.integer  "export_config_type_id", limit: 4,                  null: false
    t.integer  "field_reference_id",    limit: 4
    t.string   "field_reference_type",  limit: 255
    t.integer  "order",                 limit: 4
    t.string   "field_name",            limit: 255
    t.boolean  "spreadsheet",                       default: true
    t.boolean  "pdf",                               default: true
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  add_index "export_configs", ["company_id"], name: "index_export_configs_on_company_id", using: :btree
  add_index "export_configs", ["export_config_type_id"], name: "index_export_configs_on_export_config_type_id", using: :btree

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
    t.boolean  "bank_account_reimbursement"
    t.boolean  "payroll_card_enabled",                   default: false
    t.boolean  "current_account_connected"
    t.boolean  "invoicing_system",                       default: false
    t.boolean  "travel_request",                         default: false
    t.boolean  "budgeting_system",                       default: false
    t.boolean  "em_tax_tracking",                        default: false
    t.boolean  "procurement",                            default: false
    t.boolean  "custom_currency_conversion",             default: false
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
    t.boolean  "enabled",                             default: true,  null: false
    t.integer  "field_type_id",           limit: 4,                   null: false
    t.boolean  "mandatory",                           default: false, null: false
    t.integer  "company_id",              limit: 4,                   null: false
    t.integer  "configurable_id",         limit: 4
    t.string   "configurable_type",       limit: 255,                 null: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "field_name",              limit: 255,                 null: false
    t.integer  "default_value_id",        limit: 4
    t.string   "default_value_type",      limit: 255
    t.boolean  "is_deleted",                          default: false, null: false
    t.boolean  "global",                              default: true
    t.string   "external_reference_type", limit: 255
    t.integer  "external_reference_id",   limit: 4
    t.integer  "parent_id",               limit: 4
    t.string   "parent_type",             limit: 255
    t.boolean  "root_field",                          default: true
    t.string   "field_key",               limit: 255
    t.integer  "sequence_number",         limit: 4
  end

  add_index "field_configurations", ["company_id"], name: "index_field_configurations_on_company_id", using: :btree
  add_index "field_configurations", ["configurable_id"], name: "index_field_configurations_on_configurable_id", using: :btree
  add_index "field_configurations", ["configurable_type"], name: "index_field_configurations_on_configurable_type", using: :btree
  add_index "field_configurations", ["field_type_id"], name: "index_field_configurations_on_field_type_id", using: :btree

  create_table "field_customizations", force: :cascade do |t|
    t.string   "class_name",    limit: 255,                 null: false
    t.string   "field_name",    limit: 255,                 null: false
    t.boolean  "enabled",                   default: false, null: false
    t.boolean  "presence",                  default: false, null: false
    t.boolean  "show_in_pdf",               default: false, null: false
    t.integer  "scopable_id",   limit: 4,                   null: false
    t.string   "scopable_type", limit: 255,                 null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "field_customizations", ["class_name"], name: "index_field_customizations_on_class_name", using: :btree
  add_index "field_customizations", ["enabled"], name: "index_field_customizations_on_enabled", using: :btree
  add_index "field_customizations", ["field_name"], name: "index_field_customizations_on_field_name", using: :btree
  add_index "field_customizations", ["presence"], name: "index_field_customizations_on_presence", using: :btree
  add_index "field_customizations", ["scopable_type", "scopable_id"], name: "index_field_customizations_on_scopable_type_and_scopable_id", using: :btree
  add_index "field_customizations", ["show_in_pdf"], name: "index_field_customizations_on_show_in_pdf", using: :btree

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
    t.string   "name",                   limit: 255,                 null: false
    t.integer  "field_configuration_id", limit: 4,                   null: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.boolean  "is_deleted",                         default: false
  end

  add_index "field_drop_down_items", ["field_configuration_id"], name: "index_field_drop_down_items_on_field_configuration_id", using: :btree

  create_table "field_drop_down_selections", force: :cascade do |t|
    t.integer  "value_id",   limit: 4, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "field_drop_down_selections", ["value_id"], name: "index_field_drop_down_selections_on_value_id", using: :btree

  create_table "field_multiselect_items", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "field_configuration_id", limit: 4
    t.boolean  "is_deleted"
  end

  create_table "field_multiselect_selection_items", force: :cascade do |t|
    t.integer  "value_id",                       limit: 4
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "field_multiselect_selection_id", limit: 4
  end

  add_index "field_multiselect_selection_items", ["value_id"], name: "index_field_multiselect_selection_items_on_value_id", using: :btree

  create_table "field_multiselect_selections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "field_numbers", force: :cascade do |t|
    t.text     "value",      limit: 65535, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "field_parent_mappings", force: :cascade do |t|
    t.integer  "field_configuration_id", limit: 4, null: false
    t.integer  "field_parent_type_id",   limit: 4, null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "field_parent_mappings", ["field_configuration_id"], name: "index_field_parent_mappings_on_field_configuration_id", using: :btree
  add_index "field_parent_mappings", ["field_parent_type_id"], name: "index_field_parent_mappings_on_field_parent_type_id", using: :btree

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
    t.integer  "sequence_number",             limit: 4
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

  create_table "gst_state_codes", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "state_code", limit: 255
  end

  create_table "gst_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "gst_types", ["name"], name: "index_gst_types_on_name", using: :btree

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
    t.string   "aadhar_front_file_name",     limit: 255
    t.string   "aadhar_front_content_type",  limit: 255
    t.integer  "aadhar_front_file_size",     limit: 4
    t.datetime "aadhar_front_updated_at"
    t.string   "aadhar_back_file_name",      limit: 255
    t.string   "aadhar_back_content_type",   limit: 255
    t.integer  "aadhar_back_file_size",      limit: 4
    t.datetime "aadhar_back_updated_at"
    t.string   "photo_file_name",            limit: 255
    t.string   "photo_content_type",         limit: 255
    t.integer  "photo_file_size",            limit: 4
    t.datetime "photo_updated_at"
    t.string   "signature_file_name",        limit: 255
    t.string   "signature_content_type",     limit: 255
    t.integer  "signature_file_size",        limit: 4
    t.datetime "signature_updated_at"
    t.string   "combined_kyc_file_name",     limit: 255
    t.string   "combined_kyc_content_type",  limit: 255
    t.integer  "combined_kyc_file_size",     limit: 4
    t.datetime "combined_kyc_updated_at"
  end

  add_index "individual_kycs", ["admin_review_workflow_id"], name: "index_individual_kycs_on_admin_review_workflow_id", using: :btree
  add_index "individual_kycs", ["company_id"], name: "index_individual_kycs_on_company_id", using: :btree
  add_index "individual_kycs", ["user_id"], name: "index_individual_kycs_on_user_id", using: :btree

  create_table "inventory_line_items", force: :cascade do |t|
    t.decimal  "tax",                       precision: 20, scale: 10
    t.decimal  "discount",                  precision: 20, scale: 10
    t.string   "hsn_sac",     limit: 255
    t.integer  "company_id",  limit: 4
    t.string   "sku",         limit: 255
    t.decimal  "rate",                      precision: 20, scale: 10
    t.text     "description", limit: 65535
    t.integer  "category_id", limit: 4
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.text     "note",        limit: 65535
    t.integer  "tax_rate_id", limit: 4
    t.boolean  "is_deleted",                                          default: false, null: false
    t.string   "item_code",   limit: 255
    t.string   "account",     limit: 255
  end

  add_index "inventory_line_items", ["category_id"], name: "index_inventory_line_items_on_category_id", using: :btree
  add_index "inventory_line_items", ["company_id"], name: "index_inventory_line_items_on_company_id", using: :btree
  add_index "inventory_line_items", ["tax_rate_id"], name: "index_inventory_line_items_on_tax_rate_id", using: :btree

  create_table "invoice_attachments", force: :cascade do |t|
    t.string   "attached_file_file_name",    limit: 255
    t.string   "attached_file_content_type", limit: 255
    t.integer  "attached_file_file_size",    limit: 4
    t.datetime "attached_file_updated_at"
    t.integer  "invoice_id",                 limit: 4
    t.text     "description",                limit: 65535
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "company_id",                 limit: 4
  end

  add_index "invoice_attachments", ["invoice_id"], name: "index_invoice_attachments_on_invoice_id", using: :btree

  create_table "invoice_line_items", force: :cascade do |t|
    t.integer  "invoice_id",             limit: 4
    t.string   "description",            limit: 255
    t.integer  "quantity",               limit: 4
    t.decimal  "rate",                                 precision: 20, scale: 10
    t.decimal  "tax",                                  precision: 20, scale: 10
    t.decimal  "discount",                             precision: 20, scale: 10
    t.integer  "category_id",            limit: 4
    t.integer  "gst_type_id",            limit: 4
    t.integer  "tax_amount_id",          limit: 4
    t.integer  "discount_amount_id",     limit: 4
    t.integer  "amount_id",              limit: 4
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.integer  "net_amount_id",          limit: 4
    t.string   "hsn_sac",                limit: 255
    t.integer  "taxable_amount_id",      limit: 4
    t.string   "parent_type",            limit: 255
    t.string   "parent_id",              limit: 255
    t.integer  "inventory_line_item_id", limit: 4
    t.text     "item_info",              limit: 65535
    t.string   "comment",                limit: 255
    t.string   "account",                limit: 255
    t.integer  "tax_rate_id",            limit: 4
  end

  add_index "invoice_line_items", ["category_id"], name: "index_invoice_line_items_on_category_id", using: :btree
  add_index "invoice_line_items", ["discount_amount_id"], name: "index_invoice_line_items_on_discount_amount_id", using: :btree
  add_index "invoice_line_items", ["gst_type_id"], name: "index_invoice_line_items_on_gst_type_id", using: :btree
  add_index "invoice_line_items", ["invoice_id"], name: "index_invoice_line_items_on_invoice_id", using: :btree
  add_index "invoice_line_items", ["tax_amount_id"], name: "index_invoice_line_items_on_tax_amount_id", using: :btree

  create_table "invoice_number_config_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "invoice_number_configs", force: :cascade do |t|
    t.string   "prefix",                        limit: 255, default: ""
    t.string   "sequence_start",                limit: 255
    t.integer  "company_id",                    limit: 4
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.integer  "invoice_number_config_type_id", limit: 4
    t.integer  "purpose_id",                    limit: 4
  end

  add_index "invoice_number_configs", ["invoice_number_config_type_id"], name: "index_invoice_number_configs_on_invoice_number_config_type_id", using: :btree
  add_index "invoice_number_configs", ["purpose_id"], name: "index_invoice_number_configs_on_purpose_id", using: :btree

  create_table "invoice_reminders", force: :cascade do |t|
    t.integer  "days",                limit: 4
    t.string   "reference_date_type", limit: 255
    t.string   "timeframe_type",      limit: 255
    t.integer  "company_id",          limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "name",                limit: 255
  end

  create_table "invoice_transaction_mappings", force: :cascade do |t|
    t.integer  "invoice_id",        limit: 4
    t.integer  "va_transaction_id", limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "invoice_transaction_mappings", ["invoice_id"], name: "index_invoice_transaction_mappings_on_invoice_id", using: :btree
  add_index "invoice_transaction_mappings", ["va_transaction_id"], name: "index_invoice_transaction_mappings_on_va_transaction_id", using: :btree

  create_table "invoices", force: :cascade do |t|
    t.integer  "address_id",                   limit: 4
    t.date     "date"
    t.date     "due_date"
    t.text     "invoice_number",               limit: 65535
    t.integer  "tax_type_id",                  limit: 4
    t.decimal  "discount",                                   precision: 64, scale: 12
    t.integer  "discount_type_id",             limit: 4
    t.datetime "created_at",                                                                           null: false
    t.datetime "updated_at",                                                                           null: false
    t.integer  "gross_amount_id",              limit: 4
    t.integer  "net_amount_id",                limit: 4
    t.boolean  "inclusive_of_taxes"
    t.integer  "amount_id",                    limit: 4
    t.decimal  "tds",                                        precision: 64, scale: 12
    t.integer  "tds_type_id",                  limit: 4
    t.integer  "gst_type_id",                  limit: 4
    t.integer  "payment_id",                   limit: 4
    t.integer  "discount_amount_id",           limit: 4
    t.integer  "tds_amount_id",                limit: 4
    t.integer  "tax_amount_id",                limit: 4
    t.decimal  "tax",                                        precision: 64, scale: 12
    t.integer  "category_id",                  limit: 4
    t.integer  "original_amount_id",           limit: 4
    t.integer  "advance_amount_id",            limit: 4
    t.integer  "advance_type_id",              limit: 4
    t.decimal  "advance",                                    precision: 20, scale: 10
    t.integer  "freight_amount_id",            limit: 4
    t.integer  "freight_type_id",              limit: 4
    t.decimal  "freight",                                    precision: 20, scale: 10
    t.decimal  "roundoff_amount",                            precision: 20, scale: 10
    t.integer  "balance_due_id",               limit: 4
    t.integer  "taxable_amount_id",            limit: 4
    t.integer  "cost_center_id",               limit: 4
    t.integer  "tds_slab_id",                  limit: 4
    t.integer  "invoice_status_id",            limit: 4
    t.integer  "company_id",                   limit: 4
    t.integer  "created_by_user_id",           limit: 4
    t.integer  "paid_amount_id",               limit: 4
    t.integer  "vendor_id",                    limit: 4
    t.integer  "receiving_account_id",         limit: 4
    t.string   "receiving_account_type",       limit: 255
    t.text     "note",                         limit: 65535
    t.integer  "procurement_id",               limit: 4
    t.integer  "remaining_amount_id",          limit: 4
    t.integer  "invoice_type_id",              limit: 4
    t.integer  "location_id",                  limit: 4
    t.integer  "delivery_location_id",         limit: 4
    t.integer  "payment_term_id",              limit: 4
    t.integer  "department_id",                limit: 4
    t.integer  "sub_department_id",            limit: 4
    t.integer  "policy_id",                    limit: 4
    t.integer  "controlling_level_id",         limit: 4
    t.integer  "controlling_user_id",          limit: 4
    t.integer  "controlling_user_role_id",     limit: 4
    t.integer  "controlling_for_user_id",      limit: 4
    t.integer  "controlling_for_user_role_id", limit: 4
    t.text     "billing_address",              limit: 65535
    t.text     "shipping_address",             limit: 65535
    t.boolean  "is_template",                                                          default: false
    t.string   "template_name",                limit: 255
    t.boolean  "is_deleted",                                                           default: false
    t.integer  "resource_template_id",         limit: 4
  end

  add_index "invoices", ["address_id"], name: "index_invoices_on_address_id", using: :btree
  add_index "invoices", ["discount_type_id"], name: "index_invoices_on_discount_type_id", using: :btree
  add_index "invoices", ["payment_term_id"], name: "index_invoices_on_payment_term_id", using: :btree
  add_index "invoices", ["tax_type_id"], name: "index_invoices_on_tax_type_id", using: :btree

  create_table "inward_document_items", force: :cascade do |t|
    t.integer  "purchase_order_item_id", limit: 4
    t.integer  "inward_document_id",     limit: 4
    t.integer  "inventory_line_item_id", limit: 4
    t.string   "product_id",             limit: 255
    t.string   "description",            limit: 255
    t.decimal  "quantity",                           precision: 20, scale: 5
    t.decimal  "delivered",                          precision: 20, scale: 5
    t.decimal  "accepted",                           precision: 20, scale: 5
    t.decimal  "rejected",                           precision: 20, scale: 5
    t.datetime "created_at",                                                                  null: false
    t.datetime "updated_at",                                                                  null: false
    t.string   "comment",                limit: 255
    t.decimal  "previously_delivered",               precision: 20, scale: 5
    t.boolean  "is_deleted",                                                  default: false, null: false
  end

  add_index "inward_document_items", ["inventory_line_item_id"], name: "index_inward_document_items_on_inventory_line_item_id", using: :btree
  add_index "inward_document_items", ["inward_document_id"], name: "index_inward_document_items_on_inward_document_id", using: :btree
  add_index "inward_document_items", ["purchase_order_item_id"], name: "index_inward_document_items_on_purchase_order_item_id", using: :btree

  create_table "inward_documents", force: :cascade do |t|
    t.integer  "company_id",                  limit: 4
    t.integer  "procurement_id",              limit: 4
    t.integer  "vendor_id",                   limit: 4
    t.string   "doc_number",                  limit: 255
    t.string   "override_doc_number",         limit: 255
    t.string   "prefix",                      limit: 255
    t.date     "delivery_date"
    t.string   "transported_name",            limit: 255
    t.string   "transporter_document_number", limit: 255
    t.string   "vehicle_number",              limit: 255
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.boolean  "is_deleted",                              default: false, null: false
    t.integer  "user_id",                     limit: 4
  end

  add_index "inward_documents", ["company_id"], name: "index_inward_documents_on_company_id", using: :btree
  add_index "inward_documents", ["procurement_id"], name: "index_inward_documents_on_procurement_id", using: :btree
  add_index "inward_documents", ["user_id"], name: "index_inward_documents_on_user_id", using: :btree
  add_index "inward_documents", ["vendor_id"], name: "index_inward_documents_on_vendor_id", using: :btree

  create_table "inward_invoice_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "inward_invoice_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

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

  create_table "level_reviewer_mappings", force: :cascade do |t|
    t.integer  "level_id",    limit: 4
    t.integer  "reviewer_id", limit: 4
    t.decimal  "threshold",             precision: 20, scale: 5, default: 0.0
    t.boolean  "exception",                                      default: false
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
  end

  add_index "level_reviewer_mappings", ["level_id"], name: "index_level_reviewer_mappings_on_level_id", using: :btree
  add_index "level_reviewer_mappings", ["reviewer_id"], name: "index_level_reviewer_mappings_on_reviewer_id", using: :btree

  create_table "locations", force: :cascade do |t|
    t.integer  "locatable_id",   limit: 4
    t.string   "locatable_type", limit: 255
    t.decimal  "latitude",                     precision: 30, scale: 15
    t.decimal  "longitude",                    precision: 30, scale: 15
    t.string   "name",           limit: 255
    t.text     "address",        limit: 65535
    t.datetime "created_at",                                                             null: false
    t.datetime "updated_at",                                                             null: false
    t.integer  "order",          limit: 4
    t.string   "maps_id",        limit: 255
    t.boolean  "is_deleted",                                             default: false
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

  create_table "manager_summary_mail_configs", force: :cascade do |t|
    t.integer  "user_id",                limit: 4,   null: false
    t.integer  "period_id",              limit: 4,   null: false
    t.integer  "scheduled_day_of_month", limit: 4
    t.string   "scheduled_day_of_week",  limit: 255
    t.string   "scheduled_time",         limit: 255, null: false
    t.string   "entity_type",            limit: 255, null: false
    t.string   "application",            limit: 255, null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "manager_summary_mail_configs", ["application"], name: "index_manager_summary_mail_configs_on_application", using: :btree
  add_index "manager_summary_mail_configs", ["entity_type"], name: "index_manager_summary_mail_configs_on_entity_type", using: :btree
  add_index "manager_summary_mail_configs", ["period_id"], name: "index_manager_summary_mail_configs_on_period_id", using: :btree
  add_index "manager_summary_mail_configs", ["scheduled_day_of_month"], name: "index_manager_summary_mail_configs_on_scheduled_day_of_month", using: :btree
  add_index "manager_summary_mail_configs", ["scheduled_day_of_week"], name: "index_manager_summary_mail_configs_on_scheduled_day_of_week", using: :btree
  add_index "manager_summary_mail_configs", ["scheduled_time"], name: "index_manager_summary_mail_configs_on_scheduled_time", using: :btree
  add_index "manager_summary_mail_configs", ["user_id"], name: "index_manager_summary_mail_configs_on_user_id", using: :btree

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

  create_table "money_request_item_categories", force: :cascade do |t|
    t.integer  "company_id", limit: 4,                  null: false
    t.string   "name",       limit: 255,                null: false
    t.boolean  "active",                 default: true, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "money_request_item_categories", ["active"], name: "index_money_request_item_categories_on_active", using: :btree
  add_index "money_request_item_categories", ["company_id"], name: "index_money_request_item_categories_on_company_id", using: :btree
  add_index "money_request_item_categories", ["name"], name: "index_money_request_item_categories_on_name", using: :btree

  create_table "money_request_items", force: :cascade do |t|
    t.integer  "money_request_id",               limit: 4, null: false
    t.integer  "category_id",                    limit: 4
    t.integer  "amount_id",                      limit: 4, null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "money_request_item_category_id", limit: 4
  end

  add_index "money_request_items", ["amount_id"], name: "index_money_request_items_on_amount_id", using: :btree
  add_index "money_request_items", ["category_id"], name: "index_money_request_items_on_category_id", using: :btree
  add_index "money_request_items", ["money_request_id"], name: "index_money_request_items_on_money_request_id", using: :btree

  create_table "money_request_processor_mappings", force: :cascade do |t|
    t.integer  "processor_id",               limit: 4,                     null: false
    t.integer  "user_id",                    limit: 4,                     null: false
    t.integer  "processor_accountable_id",   limit: 4
    t.string   "processor_accountable_type", limit: 255
    t.integer  "amount_id",                  limit: 4,                     null: false
    t.datetime "completed_at"
    t.boolean  "marked_as_completed",                      default: false
    t.integer  "status_id",                  limit: 4,                     null: false
    t.integer  "payment_id",                 limit: 4
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.text     "note",                       limit: 65535
  end

  add_index "money_request_processor_mappings", ["amount_id"], name: "index_money_request_processor_mappings_on_amount_id", using: :btree
  add_index "money_request_processor_mappings", ["payment_id"], name: "index_money_request_processor_mappings_on_payment_id", using: :btree
  add_index "money_request_processor_mappings", ["processor_id"], name: "index_money_request_processor_mappings_on_processor_id", using: :btree
  add_index "money_request_processor_mappings", ["status_id"], name: "index_money_request_processor_mappings_on_status_id", using: :btree
  add_index "money_request_processor_mappings", ["user_id"], name: "index_money_request_processor_mappings_on_user_id", using: :btree

  create_table "money_request_processor_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "money_request_processor_statuses", ["name"], name: "index_money_request_processor_statuses_on_name", using: :btree

  create_table "money_request_processors", force: :cascade do |t|
    t.integer  "status_id",                 limit: 4,                   null: false
    t.boolean  "is_deleted",                            default: false
    t.boolean  "payment_file_generated",                default: false
    t.datetime "payment_file_generated_at"
    t.date     "scheduled_at"
    t.datetime "completed_at"
    t.integer  "total_amount_id",           limit: 4,                   null: false
    t.integer  "processed_amount_id",       limit: 4
    t.integer  "created_by_user_id",        limit: 4
    t.integer  "created_by_user_role_id",   limit: 4
    t.integer  "source_account_id",         limit: 4
    t.string   "source_account_type",       limit: 255
    t.boolean  "marked_as_completed",                   default: false
    t.string   "payment_type",              limit: 255
    t.string   "payment_mode",              limit: 255
    t.integer  "company_id",                limit: 4,                   null: false
    t.integer  "payment_order_id",          limit: 4
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  add_index "money_request_processors", ["company_id"], name: "index_money_request_processors_on_company_id", using: :btree
  add_index "money_request_processors", ["created_by_user_id"], name: "index_money_request_processors_on_created_by_user_id", using: :btree
  add_index "money_request_processors", ["created_by_user_role_id"], name: "index_money_request_processors_on_created_by_user_role_id", using: :btree
  add_index "money_request_processors", ["payment_order_id"], name: "index_money_request_processors_on_payment_order_id", using: :btree
  add_index "money_request_processors", ["processed_amount_id"], name: "index_money_request_processors_on_processed_amount_id", using: :btree
  add_index "money_request_processors", ["scheduled_at"], name: "index_money_request_processors_on_scheduled_at", using: :btree
  add_index "money_request_processors", ["source_account_id"], name: "index_money_request_processors_on_source_account_id", using: :btree
  add_index "money_request_processors", ["source_account_type"], name: "index_money_request_processors_on_source_account_type", using: :btree
  add_index "money_request_processors", ["status_id"], name: "index_money_request_processors_on_status_id", using: :btree
  add_index "money_request_processors", ["total_amount_id"], name: "index_money_request_processors_on_total_amount_id", using: :btree

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
    t.string   "name",                               limit: 255
    t.integer  "user_id",                            limit: 4,                                   null: false
    t.integer  "policy_id",                          limit: 4,                                   null: false
    t.integer  "payment_mode_id",                    limit: 4,                                   null: false
    t.integer  "payment_id",                         limit: 4
    t.date     "required_by_date"
    t.integer  "status_id",                          limit: 4,                                   null: false
    t.integer  "controlling_user_id",                limit: 4
    t.integer  "controlling_user_role_id",           limit: 4
    t.integer  "controlling_for_user_id",            limit: 4
    t.integer  "controlling_for_user_role_id",       limit: 4
    t.integer  "loaded_by",                          limit: 4
    t.datetime "loaded_at"
    t.datetime "submitted_at",                                     precision: 6
    t.text     "memo",                               limit: 65535
    t.boolean  "accounted",                                                      default: false, null: false
    t.datetime "created_at",                                                                     null: false
    t.datetime "updated_at",                                                                     null: false
    t.boolean  "is_deleted",                                                     default: false, null: false
    t.integer  "submitted_amount_id",                limit: 4
    t.integer  "processed_amount_id",                limit: 4
    t.boolean  "auto_approve"
    t.integer  "money_request_processor_mapping_id", limit: 4
    t.datetime "approved_at"
    t.integer  "travel_request_id",                  limit: 4
    t.integer  "destination_pocket_id",              limit: 4
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
  add_index "money_requests", ["travel_request_id"], name: "index_money_requests_on_travel_request_id", using: :btree
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
    t.string   "application",          limit: 255
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

  create_table "outward_invoice_attachments", force: :cascade do |t|
    t.string   "attachment_file_name",    limit: 255
    t.string   "attachment_content_type", limit: 255
    t.integer  "attachment_file_size",    limit: 4
    t.datetime "attachment_updated_at"
    t.integer  "outward_invoice_id",      limit: 4
    t.text     "description",             limit: 65535
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "company_id",              limit: 4
    t.integer  "user_id",                 limit: 4
  end

  add_index "outward_invoice_attachments", ["company_id"], name: "index_outward_invoice_attachments_on_company_id", using: :btree
  add_index "outward_invoice_attachments", ["outward_invoice_id"], name: "index_outward_invoice_attachments_on_outward_invoice_id", using: :btree
  add_index "outward_invoice_attachments", ["user_id"], name: "index_outward_invoice_attachments_on_user_id", using: :btree

  create_table "outward_invoice_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "outward_invoice_trail_actions", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "outward_invoice_trails", force: :cascade do |t|
    t.integer  "action_id",                   limit: 4
    t.integer  "outward_invoice_id",          limit: 4
    t.integer  "user_id",                     limit: 4
    t.string   "note",                        limit: 255
    t.integer  "amount_id",                   limit: 4
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "associated_entity_id",        limit: 4
    t.string   "associated_entity_type",      limit: 255
    t.integer  "associated_transaction_id",   limit: 4
    t.string   "associated_transaction_type", limit: 255
    t.date     "date"
  end

  add_index "outward_invoice_trails", ["action_id"], name: "index_outward_invoice_trails_on_action_id", using: :btree
  add_index "outward_invoice_trails", ["amount_id"], name: "index_outward_invoice_trails_on_amount_id", using: :btree
  add_index "outward_invoice_trails", ["associated_entity_type", "associated_entity_id"], name: "index_outward_inv_trail_on_assoc_entty_type_and_assoc_entity_id", using: :btree
  add_index "outward_invoice_trails", ["associated_transaction_type", "associated_transaction_id"], name: "index_outward_inv_trail_on_assoc_tranx_type_and_assoc_tranx_id", using: :btree
  add_index "outward_invoice_trails", ["outward_invoice_id"], name: "index_outward_invoice_trails_on_outward_invoice_id", using: :btree
  add_index "outward_invoice_trails", ["user_id"], name: "index_outward_invoice_trails_on_user_id", using: :btree

  create_table "outward_invoice_types", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "outward_invoices", force: :cascade do |t|
    t.integer  "customer_id",             limit: 4
    t.date     "date"
    t.date     "due_date"
    t.integer  "amount_id",               limit: 4
    t.integer  "discount_amount_id",      limit: 4
    t.integer  "tax_amount_id",           limit: 4
    t.integer  "paid_amount_id",          limit: 4
    t.decimal  "advance",                               precision: 10, scale: 5
    t.integer  "freight_amount_id",       limit: 4
    t.integer  "balance_due_id",          limit: 4
    t.decimal  "roundoff_amount",                       precision: 10, scale: 5
    t.datetime "created_at",                                                                 null: false
    t.datetime "updated_at",                                                                 null: false
    t.integer  "policy_id",               limit: 4
    t.integer  "invoice_status_id",       limit: 4
    t.integer  "company_id",              limit: 4
    t.string   "invoice_number",          limit: 255
    t.integer  "gst_type_id",             limit: 4
    t.boolean  "inclusive_of_taxes"
    t.integer  "advance_amount_id",       limit: 4
    t.integer  "net_amount_id",           limit: 4
    t.integer  "virtual_account_id",      limit: 4
    t.text     "billing_address",         limit: 65535
    t.text     "shipping_address",        limit: 65535
    t.string   "email",                   limit: 255
    t.string   "mobile_number",           limit: 255
    t.boolean  "override_invoice_number"
    t.boolean  "is_deleted"
    t.string   "sequence_start",          limit: 255
    t.string   "prefix",                  limit: 255
    t.integer  "total_payable_id",        limit: 4
    t.boolean  "roundoff_total_enabled"
    t.string   "memo",                    limit: 255
    t.text     "customer_memo",           limit: 65535
    t.text     "reminders",               limit: 65535
    t.integer  "payment_term_id",         limit: 4
    t.integer  "user_id",                 limit: 4
    t.integer  "outward_invoice_type_id", limit: 4,                              default: 1
    t.text     "terms",                   limit: 65535
    t.integer  "location_id",             limit: 4
  end

  add_index "outward_invoices", ["amount_id"], name: "index_outward_invoices_on_amount_id", using: :btree
  add_index "outward_invoices", ["balance_due_id"], name: "index_outward_invoices_on_balance_due_id", using: :btree
  add_index "outward_invoices", ["customer_id"], name: "index_outward_invoices_on_customer_id", using: :btree
  add_index "outward_invoices", ["discount_amount_id"], name: "index_outward_invoices_on_discount_amount_id", using: :btree
  add_index "outward_invoices", ["freight_amount_id"], name: "index_outward_invoices_on_freight_amount_id", using: :btree
  add_index "outward_invoices", ["location_id"], name: "index_outward_invoices_on_location_id", using: :btree
  add_index "outward_invoices", ["outward_invoice_type_id"], name: "index_outward_invoices_on_outward_invoice_type_id", using: :btree
  add_index "outward_invoices", ["paid_amount_id"], name: "index_outward_invoices_on_paid_amount_id", using: :btree
  add_index "outward_invoices", ["payment_term_id"], name: "index_outward_invoices_on_payment_term_id", using: :btree
  add_index "outward_invoices", ["tax_amount_id"], name: "index_outward_invoices_on_tax_amount_id", using: :btree
  add_index "outward_invoices", ["user_id"], name: "index_outward_invoices_on_user_id", using: :btree

  create_table "parent_dependent_field_configuration_mappings", force: :cascade do |t|
    t.integer  "parent_id",                        limit: 4
    t.string   "parent_type",                      limit: 255
    t.integer  "dependent_field_configuration_id", limit: 4
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  create_table "payment_file_configurations", force: :cascade do |t|
    t.string   "file_format", limit: 255
    t.integer  "company_id",  limit: 4,     null: false
    t.text     "options",     limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "payment_file_configurations", ["company_id"], name: "index_payment_file_configurations_on_company_id", using: :btree

  create_table "payment_modes", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "payment_order_attachments", force: :cascade do |t|
    t.string   "attached_file_file_name",    limit: 255
    t.string   "attached_file_content_type", limit: 255
    t.integer  "attached_file_file_size",    limit: 4
    t.datetime "attached_file_updated_at"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "payment_order_id",           limit: 4
    t.text     "description",                limit: 65535
    t.integer  "uploader_id",                limit: 4
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
    t.integer  "initiating_user_id",        limit: 4,                     null: false
    t.integer  "payment_order_status_id",   limit: 4,                     null: false
    t.string   "payment_file_file_name",    limit: 255
    t.string   "payment_file_content_type", limit: 255
    t.integer  "payment_file_file_size",    limit: 4
    t.datetime "payment_file_updated_at"
    t.integer  "company_id",                limit: 4,                     null: false
    t.integer  "amount_requested_id",       limit: 4
    t.integer  "amount_processed_id",       limit: 4
    t.text     "note",                      limit: 65535
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.string   "initiating_account_type",   limit: 255
    t.string   "receiving_account_type",    limit: 255
    t.integer  "payment_purpose_id",        limit: 4,                     null: false
    t.integer  "currency_id",               limit: 4,                     null: false
    t.string   "application",               limit: 255
    t.string   "payment_mode",              limit: 255
    t.text     "post_operation",            limit: 65535
    t.text     "post_operation_payload",    limit: 65535
    t.boolean  "api_initiated",                           default: false
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

  create_table "payment_receivable_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "payment_receivable_transaction_trails", force: :cascade do |t|
    t.boolean  "find_payment_receivable"
    t.boolean  "creating_payment"
    t.boolean  "update_company_balance"
    t.boolean  "payment_receivable_updation"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "account_transaction_id",      limit: 4
    t.text     "note",                        limit: 65535
  end

  create_table "payment_receivables", force: :cascade do |t|
    t.integer  "customer_id",                  limit: 4
    t.integer  "amount_id",                    limit: 4
    t.text     "purpose",                      limit: 65535
    t.date     "expire_by"
    t.integer  "company_id",                   limit: 4
    t.integer  "initiating_user_id",           limit: 4
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "email",                        limit: 255
    t.integer  "payment_receivable_status_id", limit: 4
    t.integer  "payment_id",                   limit: 4
  end

  add_index "payment_receivables", ["amount_id"], name: "index_payment_receivables_on_amount_id", using: :btree
  add_index "payment_receivables", ["company_id"], name: "index_payment_receivables_on_company_id", using: :btree
  add_index "payment_receivables", ["customer_id"], name: "index_payment_receivables_on_customer_id", using: :btree
  add_index "payment_receivables", ["initiating_user_id"], name: "index_payment_receivables_on_initiating_user_id", using: :btree
  add_index "payment_receivables", ["payment_receivable_status_id"], name: "index_payment_receivables_on_payment_receivable_status_id", using: :btree

  create_table "payment_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "payment_terms", force: :cascade do |t|
    t.text     "name",        limit: 65535
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "days_after",  limit: 4
    t.text     "description", limit: 65535
    t.integer  "company_id",  limit: 4
    t.boolean  "default"
    t.boolean  "is_deleted",                default: false, null: false
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
    t.integer  "amount_id",                      limit: 4,                     null: false
    t.date     "date",                                                         null: false
    t.integer  "payment_type_id",                limit: 4,                     null: false
    t.integer  "initiating_user_id",             limit: 4
    t.integer  "receiving_user_id",              limit: 4
    t.text     "note",                           limit: 65535
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.integer  "initiating_account_id",          limit: 4
    t.string   "initiating_account_type",        limit: 255
    t.integer  "receiving_account_id",           limit: 4
    t.string   "receiving_account_type",         limit: 255
    t.integer  "payment_order_id",               limit: 4
    t.integer  "payment_status_id",              limit: 4,                     null: false
    t.string   "initiating_user_type",           limit: 255
    t.string   "receiving_user_type",            limit: 255
    t.integer  "payment_purpose_id",             limit: 4
    t.integer  "reference_resource_id",          limit: 4
    t.string   "reference_resource_type",        limit: 255
    t.string   "application",                    limit: 255
    t.string   "payment_mode",                   limit: 255
    t.string   "reference_id",                   limit: 255,                   null: false
    t.integer  "retry_count",                    limit: 4,     default: 0
    t.integer  "invoice_id",                     limit: 4
    t.string   "parent_type",                    limit: 255
    t.integer  "parent_id",                      limit: 4
    t.text     "post_operation",                 limit: 65535
    t.text     "post_operation_payload",         limit: 65535
    t.integer  "category_id",                    limit: 4
    t.boolean  "api_initiated",                                default: false
    t.integer  "original_payment_for_refund_id", limit: 4
    t.integer  "destination_pocket_id",          limit: 4
    t.date     "scheduled_at"
    t.date     "processed_at"
    t.integer  "cost_center_id",                 limit: 4
  end

  add_index "payments", ["amount_id"], name: "index_payments_on_amount_id", using: :btree
  add_index "payments", ["category_id"], name: "index_payments_on_category_id", using: :btree
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
    t.string   "name",                   limit: 255
    t.integer  "company_id",             limit: 4
    t.integer  "owner_id",               limit: 4
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.boolean  "default",                              default: false, null: false
    t.boolean  "is_deleted",                           default: false, null: false
    t.text     "description",            limit: 65535
    t.integer  "base_currency_id",       limit: 4,     default: 1
    t.string   "application",            limit: 255
    t.integer  "settlement_currency_id", limit: 4,     default: 1,     null: false
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

  create_table "policy_field_mappings", force: :cascade do |t|
    t.integer  "field_configuration_id", limit: 4, null: false
    t.integer  "policy_id",              limit: 4, null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "policy_field_mappings", ["field_configuration_id"], name: "index_policy_field_mappings_on_field_configuration_id", using: :btree
  add_index "policy_field_mappings", ["policy_id"], name: "index_policy_field_mappings_on_policy_id", using: :btree

  create_table "policy_user_mappings", force: :cascade do |t|
    t.integer  "user_id",    limit: 4,                 null: false
    t.integer  "policy_id",  limit: 4,                 null: false
    t.boolean  "admin",                default: false, null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "policy_user_mappings", ["policy_id"], name: "index_policy_user_mappings_on_policy_id", using: :btree
  add_index "policy_user_mappings", ["user_id"], name: "index_policy_user_mappings_on_user_id", using: :btree

  create_table "policy_user_roles", force: :cascade do |t|
    t.integer  "policy_id",    limit: 4
    t.integer  "user_id",      limit: 4
    t.integer  "user_role_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "policy_user_roles", ["policy_id"], name: "index_policy_user_roles_on_policy_id", using: :btree
  add_index "policy_user_roles", ["user_id"], name: "index_policy_user_roles_on_user_id", using: :btree
  add_index "policy_user_roles", ["user_role_id"], name: "index_policy_user_roles_on_user_role_id", using: :btree

  create_table "post_operation_actions", force: :cascade do |t|
    t.string   "operation",            limit: 255,   null: false
    t.text     "payload",              limit: 65535
    t.integer  "post_operatable_id",   limit: 4,     null: false
    t.string   "post_operatable_type", limit: 255,   null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "post_operation_actions", ["operation"], name: "index_post_operation_actions_on_operation", using: :btree
  add_index "post_operation_actions", ["post_operatable_id"], name: "index_post_operation_actions_on_post_operatable_id", using: :btree
  add_index "post_operation_actions", ["post_operatable_type"], name: "index_post_operation_actions_on_post_operatable_type", using: :btree

  create_table "preview_registrations", force: :cascade do |t|
    t.string   "email",              limit: 255
    t.text     "company",            limit: 65535
    t.string   "phone_number",       limit: 255
    t.text     "name",               limit: 65535
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.text     "source",             limit: 65535
    t.text     "source_description", limit: 65535
    t.string   "referrer",           limit: 255
  end

  create_table "procurement_attachments", force: :cascade do |t|
    t.string   "file_file_name",            limit: 255
    t.string   "file_content_type",         limit: 255
    t.integer  "file_file_size",            limit: 4
    t.datetime "file_updated_at"
    t.string   "name",                      limit: 255
    t.integer  "company_id",                limit: 4
    t.text     "description",               limit: 65535
    t.integer  "procurement_document_id",   limit: 4
    t.string   "procurement_document_type", limit: 255
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "procurement_charges", force: :cascade do |t|
    t.integer  "charge_type",     limit: 4
    t.string   "description",     limit: 255
    t.integer  "amount_id",       limit: 4
    t.boolean  "taxable"
    t.decimal  "tax",                         precision: 10
    t.integer  "tax_amount_id",   limit: 4
    t.integer  "total_amount_id", limit: 4
    t.integer  "chargable_id",    limit: 4
    t.string   "chargable_type",  limit: 255
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "procurement_charges", ["amount_id"], name: "index_procurement_charges_on_amount_id", using: :btree
  add_index "procurement_charges", ["chargable_type", "chargable_id"], name: "index_procurement_charges_on_chargable_type_and_chargable_id", using: :btree
  add_index "procurement_charges", ["tax_amount_id"], name: "index_procurement_charges_on_tax_amount_id", using: :btree
  add_index "procurement_charges", ["total_amount_id"], name: "index_procurement_charges_on_total_amount_id", using: :btree

  create_table "procurement_comments", force: :cascade do |t|
    t.text     "body",                    limit: 65535
    t.integer  "user_id",                 limit: 4
    t.integer  "parent_commentable_id",   limit: 4
    t.string   "parent_commentable_type", limit: 255
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.boolean  "is_deleted",                            default: false, null: false
  end

  add_index "procurement_comments", ["parent_commentable_type", "parent_commentable_id"], name: "indx_prcurmnt_cmments_on_prnt_cmmentble_typ_n_prnt_cmmentble_id", using: :btree
  add_index "procurement_comments", ["user_id"], name: "index_procurement_comments_on_user_id", using: :btree

  create_table "procurement_status_taggables", force: :cascade do |t|
    t.integer  "procurement_id", limit: 4
    t.integer  "status_tag_id",  limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "procurement_status_taggables", ["procurement_id"], name: "index_procurement_status_taggables_on_procurement_id", using: :btree
  add_index "procurement_status_taggables", ["status_tag_id"], name: "index_procurement_status_taggables_on_status_tag_id", using: :btree

  create_table "procurement_statuses", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "procurement_terms", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "company_id",  limit: 4
    t.boolean  "is_deleted",                default: false, null: false
  end

  add_index "procurement_terms", ["company_id"], name: "index_procurement_terms_on_company_id", using: :btree

  create_table "procurement_tracks", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "procurements", force: :cascade do |t|
    t.string   "name",                  limit: 255
    t.integer  "procurement_track_id",  limit: 4
    t.integer  "procurement_status_id", limit: 4
    t.integer  "vendor_id",             limit: 4
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "user_id",               limit: 4
    t.integer  "company_id",            limit: 4
    t.text     "note",                  limit: 65535
    t.boolean  "is_deleted",                          default: false, null: false
    t.string   "procurement_type",      limit: 255
    t.string   "transaction_id",        limit: 255
  end

  add_index "procurements", ["company_id"], name: "index_procurements_on_company_id", using: :btree
  add_index "procurements", ["procurement_status_id"], name: "index_procurements_on_procurement_status_id", using: :btree
  add_index "procurements", ["procurement_track_id"], name: "index_procurements_on_procurement_track_id", using: :btree
  add_index "procurements", ["user_id"], name: "index_procurements_on_user_id", using: :btree
  add_index "procurements", ["vendor_id"], name: "index_procurements_on_vendor_id", using: :btree

  create_table "product_combinations", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "product_pricing_queries", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.string   "mobile_number",        limit: 255
    t.string   "email",                limit: 255
    t.string   "employees",            limit: 255
    t.string   "accounting_system",    limit: 255
    t.string   "monthly_transactions", limit: 255
    t.string   "monthly_invoices",     limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "product",              limit: 255
    t.string   "prepaid_cards",        limit: 255
  end

  create_table "purchase_order_items", force: :cascade do |t|
    t.integer  "purchase_order_id",      limit: 4
    t.integer  "inventory_line_item_id", limit: 4
    t.string   "product_id",             limit: 255
    t.string   "description",            limit: 255
    t.string   "hsn_sac",                limit: 255
    t.integer  "quantity",               limit: 4
    t.decimal  "rate",                                 precision: 20, scale: 5
    t.decimal  "tax",                                  precision: 20, scale: 5
    t.decimal  "tds",                                  precision: 20, scale: 5
    t.decimal  "discount",                             precision: 20, scale: 5
    t.integer  "tax_amount_id",          limit: 4
    t.integer  "tds_amount_id",          limit: 4
    t.integer  "discount_amount_id",     limit: 4
    t.integer  "total_amount_id",        limit: 4
    t.date     "delivery_date"
    t.text     "comment",                limit: 65535
    t.datetime "created_at",                                                                    null: false
    t.datetime "updated_at",                                                                    null: false
    t.integer  "delivered",              limit: 4,                              default: 0
    t.integer  "accepted",               limit: 4,                              default: 0
    t.integer  "rejected",               limit: 4,                              default: 0
    t.integer  "category_id",            limit: 4
    t.integer  "cost_center_id",         limit: 4
    t.boolean  "is_deleted",                                                    default: false, null: false
    t.string   "account",                limit: 255
    t.integer  "tax_rate_id",            limit: 4
  end

  add_index "purchase_order_items", ["discount_amount_id"], name: "index_purchase_order_items_on_discount_amount_id", using: :btree
  add_index "purchase_order_items", ["inventory_line_item_id"], name: "index_purchase_order_items_on_inventory_line_item_id", using: :btree
  add_index "purchase_order_items", ["purchase_order_id"], name: "index_purchase_order_items_on_purchase_order_id", using: :btree
  add_index "purchase_order_items", ["tax_amount_id"], name: "index_purchase_order_items_on_tax_amount_id", using: :btree
  add_index "purchase_order_items", ["tds_amount_id"], name: "index_purchase_order_items_on_tds_amount_id", using: :btree
  add_index "purchase_order_items", ["total_amount_id"], name: "index_purchase_order_items_on_total_amount_id", using: :btree

  create_table "purchase_order_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "purchase_orders", force: :cascade do |t|
    t.integer  "company_id",                   limit: 4
    t.integer  "procurement_id",               limit: 4
    t.integer  "location_id",                  limit: 4
    t.integer  "delivery_location_id",         limit: 4
    t.integer  "vendor_id",                    limit: 4
    t.integer  "payment_term_id",              limit: 4
    t.integer  "procurement_term_id",          limit: 4
    t.integer  "purchase_order_status_id",     limit: 4
    t.string   "indent_number",                limit: 255
    t.date     "indent_date"
    t.string   "po_number",                    limit: 255
    t.boolean  "override_po_number"
    t.string   "prefix",                       limit: 255
    t.string   "sequence_start",               limit: 255
    t.date     "delivery_date"
    t.integer  "gst_type_id",                  limit: 4
    t.boolean  "inclusive_of_taxes"
    t.boolean  "roundoff_total_enabled"
    t.decimal  "roundoff_amount",                            precision: 10, scale: 5
    t.integer  "transaction_amount_id",        limit: 4
    t.integer  "total_before_tax_id",          limit: 4
    t.integer  "tax_amount_id",                limit: 4
    t.integer  "total_after_tax_id",           limit: 4
    t.integer  "discount_amount_id",           limit: 4
    t.integer  "balance_amount_id",            limit: 4
    t.datetime "created_at",                                                                          null: false
    t.datetime "updated_at",                                                                          null: false
    t.integer  "user_id",                      limit: 4
    t.text     "procurement_term_text",        limit: 65535
    t.integer  "controlling_user_id",          limit: 4
    t.integer  "controlling_user_role_id",     limit: 4
    t.integer  "controlling_for_user_id",      limit: 4
    t.integer  "controlling_for_user_role_id", limit: 4
    t.integer  "policy_id",                    limit: 4
    t.integer  "controlling_level_id",         limit: 4
    t.integer  "department_id",                limit: 4
    t.boolean  "is_deleted",                                                          default: false, null: false
    t.integer  "cost_center_id",               limit: 4
    t.integer  "sub_department_id",            limit: 4
    t.text     "billing_address",              limit: 65535
    t.text     "shipping_address",             limit: 65535
    t.boolean  "is_template",                                                         default: false
    t.string   "template_name",                limit: 255
    t.integer  "resource_template_id",         limit: 4
  end

  add_index "purchase_orders", ["balance_amount_id"], name: "index_purchase_orders_on_balance_amount_id", using: :btree
  add_index "purchase_orders", ["company_id"], name: "index_purchase_orders_on_company_id", using: :btree
  add_index "purchase_orders", ["delivery_location_id"], name: "index_purchase_orders_on_delivery_location_id", using: :btree
  add_index "purchase_orders", ["discount_amount_id"], name: "index_purchase_orders_on_discount_amount_id", using: :btree
  add_index "purchase_orders", ["gst_type_id"], name: "fk_rails_a50fbe2826", using: :btree
  add_index "purchase_orders", ["location_id"], name: "index_purchase_orders_on_location_id", using: :btree
  add_index "purchase_orders", ["payment_term_id"], name: "index_purchase_orders_on_payment_term_id", using: :btree
  add_index "purchase_orders", ["policy_id"], name: "index_purchase_orders_on_policy_id", using: :btree
  add_index "purchase_orders", ["procurement_id"], name: "index_purchase_orders_on_procurement_id", using: :btree
  add_index "purchase_orders", ["procurement_term_id"], name: "index_purchase_orders_on_procurement_term_id", using: :btree
  add_index "purchase_orders", ["purchase_order_status_id"], name: "index_purchase_orders_on_purchase_order_status_id", using: :btree
  add_index "purchase_orders", ["tax_amount_id"], name: "index_purchase_orders_on_tax_amount_id", using: :btree
  add_index "purchase_orders", ["total_after_tax_id"], name: "index_purchase_orders_on_total_after_tax_id", using: :btree
  add_index "purchase_orders", ["total_before_tax_id"], name: "index_purchase_orders_on_total_before_tax_id", using: :btree
  add_index "purchase_orders", ["transaction_amount_id"], name: "index_purchase_orders_on_transaction_amount_id", using: :btree
  add_index "purchase_orders", ["user_id"], name: "index_purchase_orders_on_user_id", using: :btree
  add_index "purchase_orders", ["vendor_id"], name: "index_purchase_orders_on_vendor_id", using: :btree

  create_table "purposes", force: :cascade do |t|
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

  create_table "quickbooks_departments", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.integer  "quickbooks_id",          limit: 4
    t.boolean  "active"
    t.integer  "company_id",             limit: 4
    t.text     "additional_information", limit: 65535
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "quickbooks_departments", ["company_id"], name: "index_quickbooks_departments_on_company_id", using: :btree

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

  create_table "quickbooks_reference_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "quickbooks_references", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.integer  "company_id",        limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "reference_type_id", limit: 4
  end

  create_table "rate_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

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

  create_table "report_processor_group_mappings", force: :cascade do |t|
    t.integer  "processor_group_id",         limit: 4,                     null: false
    t.integer  "user_id",                    limit: 4,                     null: false
    t.integer  "processor_accountable_id",   limit: 4
    t.string   "processor_accountable_type", limit: 255
    t.integer  "amount_id",                  limit: 4,                     null: false
    t.datetime "completed_at"
    t.boolean  "marked_as_completed",                      default: false
    t.integer  "status_id",                  limit: 4,                     null: false
    t.integer  "payment_id",                 limit: 4
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.text     "note",                       limit: 65535
    t.boolean  "marked_as_closed"
  end

  add_index "report_processor_group_mappings", ["amount_id"], name: "index_report_processor_group_mappings_on_amount_id", using: :btree
  add_index "report_processor_group_mappings", ["payment_id"], name: "index_report_processor_group_mappings_on_payment_id", using: :btree
  add_index "report_processor_group_mappings", ["processor_group_id"], name: "index_report_processor_group_mappings_on_processor_group_id", using: :btree
  add_index "report_processor_group_mappings", ["status_id"], name: "index_report_processor_group_mappings_on_status_id", using: :btree
  add_index "report_processor_group_mappings", ["user_id"], name: "index_report_processor_group_mappings_on_user_id", using: :btree

  create_table "report_processor_group_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "report_processor_group_statuses", ["name"], name: "index_report_processor_group_statuses_on_name", using: :btree

  create_table "report_processor_groups", force: :cascade do |t|
    t.integer  "status_id",                 limit: 4,                   null: false
    t.boolean  "is_deleted",                            default: false
    t.boolean  "payment_file_generated",                default: false
    t.datetime "payment_file_generated_at"
    t.date     "scheduled_at"
    t.datetime "completed_at"
    t.integer  "total_amount_id",           limit: 4,                   null: false
    t.integer  "processed_amount_id",       limit: 4
    t.integer  "created_by_user_id",        limit: 4
    t.integer  "created_by_user_role_id",   limit: 4
    t.integer  "source_account_id",         limit: 4
    t.string   "source_account_type",       limit: 255
    t.boolean  "marked_as_completed",                   default: false
    t.string   "payment_type",              limit: 255
    t.string   "payment_mode",              limit: 255
    t.integer  "company_id",                limit: 4,                   null: false
    t.integer  "payment_order_id",          limit: 4
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.boolean  "marked_as_closed"
    t.boolean  "tally_exported",                        default: false
  end

  add_index "report_processor_groups", ["company_id"], name: "index_report_processor_groups_on_company_id", using: :btree
  add_index "report_processor_groups", ["created_by_user_id"], name: "index_report_processor_groups_on_created_by_user_id", using: :btree
  add_index "report_processor_groups", ["created_by_user_role_id"], name: "index_report_processor_groups_on_created_by_user_role_id", using: :btree
  add_index "report_processor_groups", ["payment_order_id"], name: "index_report_processor_groups_on_payment_order_id", using: :btree
  add_index "report_processor_groups", ["processed_amount_id"], name: "index_report_processor_groups_on_processed_amount_id", using: :btree
  add_index "report_processor_groups", ["scheduled_at"], name: "index_report_processor_groups_on_scheduled_at", using: :btree
  add_index "report_processor_groups", ["source_account_id"], name: "index_report_processor_groups_on_source_account_id", using: :btree
  add_index "report_processor_groups", ["source_account_type"], name: "index_report_processor_groups_on_source_account_type", using: :btree
  add_index "report_processor_groups", ["status_id"], name: "index_report_processor_groups_on_status_id", using: :btree
  add_index "report_processor_groups", ["total_amount_id"], name: "index_report_processor_groups_on_total_amount_id", using: :btree

  create_table "report_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.integer  "order",      limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "report_sync_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "report_sync_types", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "report_sync_types", ["name"], name: "index_report_sync_types_on_name", using: :btree

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
    t.integer  "sync_status_id",                     limit: 4
    t.integer  "sync_type_id",                       limit: 4
    t.integer  "report_processor_group_mapping_id",  limit: 4
    t.integer  "travel_request_id",                  limit: 4
  end

  add_index "reports", ["controlling_for_user_id"], name: "index_reports_on_controlling_for_user_id", using: :btree
  add_index "reports", ["controlling_for_user_role_id"], name: "index_reports_on_controlling_for_user_role_id", using: :btree
  add_index "reports", ["controlling_user_id"], name: "index_reports_on_controlling_user_id", using: :btree
  add_index "reports", ["controlling_user_role_id"], name: "index_reports_on_controlling_user_role_id", using: :btree
  add_index "reports", ["name"], name: "index_reports_on_name", using: :btree
  add_index "reports", ["policy_id"], name: "index_reports_on_policy_id", using: :btree
  add_index "reports", ["report_processor_group_mapping_id"], name: "index_reports_on_report_processor_group_mapping_id", using: :btree
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

  create_table "resource_templates", force: :cascade do |t|
    t.string   "name",          limit: 255, null: false
    t.string   "resource_type", limit: 255, null: false
    t.integer  "user_id",       limit: 4,   null: false
    t.datetime "last_used_at"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "resource_templates", ["name"], name: "index_resource_templates_on_name", using: :btree
  add_index "resource_templates", ["resource_type"], name: "index_resource_templates_on_resource_type", using: :btree
  add_index "resource_templates", ["user_id"], name: "index_resource_templates_on_user_id", using: :btree

  create_table "reviewal_levels", force: :cascade do |t|
    t.integer  "level_number",           limit: 4
    t.integer  "policy_id",              limit: 4
    t.string   "associated_entity_type", limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "name",                   limit: 255
  end

  add_index "reviewal_levels", ["policy_id"], name: "index_reviewal_levels_on_policy_id", using: :btree

  create_table "rule_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "signedup_users", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "mobile_number",      limit: 255
    t.string   "email",              limit: 255
    t.string   "encrypted_password", limit: 255
    t.string   "products",           limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "company_name",       limit: 255
  end

  create_table "states", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.string   "code",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "status_tags", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "display_name",    limit: 255
    t.string   "description",     limit: 255
    t.string   "font_icon",       limit: 255
    t.string   "font_icon_color", limit: 255
    t.string   "icon_path",       limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "system_logs", force: :cascade do |t|
    t.integer  "log_resource_id",   limit: 4,     null: false
    t.string   "log_resource_type", limit: 255,   null: false
    t.integer  "type_id",           limit: 4,     null: false
    t.text     "value",             limit: 65535, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "system_logs", ["log_resource_id"], name: "index_system_logs_on_log_resource_id", using: :btree
  add_index "system_logs", ["log_resource_type"], name: "index_system_logs_on_log_resource_type", using: :btree
  add_index "system_logs", ["type_id"], name: "index_system_logs_on_type_id", using: :btree

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

  create_table "tally_configurations", force: :cascade do |t|
    t.integer  "company_id",           limit: 4,                   null: false
    t.string   "company_name",         limit: 255
    t.boolean  "active"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "voucher_expense_date", limit: 255
    t.boolean  "custom_voucher",                   default: false
  end

  add_index "tally_configurations", ["company_id"], name: "index_tally_configurations_on_company_id", using: :btree

  create_table "tax_rates", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.decimal  "rate",                    precision: 20, scale: 5
    t.string   "internal_id", limit: 255
    t.integer  "company_id",  limit: 4
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.boolean  "is_deleted",                                       default: false, null: false
  end

  add_index "tax_rates", ["company_id"], name: "index_tax_rates_on_company_id", using: :btree

  create_table "tds_rates_lists", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.decimal  "tds",                    precision: 10, scale: 5
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "company_id", limit: 4
  end

  create_table "temporary_files", force: :cascade do |t|
    t.string   "file_file_name",    limit: 255
    t.string   "file_content_type", limit: 255
    t.integer  "file_file_size",    limit: 8
    t.datetime "file_updated_at"
    t.datetime "expires_on"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "temporary_files", ["expires_on"], name: "index_temporary_files_on_expires_on", using: :btree

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

  create_table "trail_actions", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "trails", force: :cascade do |t|
    t.integer  "parent_id",           limit: 4
    t.string   "parent_type",         limit: 255
    t.integer  "action_user_id",      limit: 4
    t.integer  "action_id",           limit: 4
    t.integer  "action_user_role_id", limit: 4
    t.integer  "action_level_id",     limit: 4
    t.integer  "modified_level_id",   limit: 4
    t.text     "note",                limit: 65535
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "trails", ["action_id"], name: "index_trails_on_action_id", using: :btree
  add_index "trails", ["action_level_id"], name: "index_trails_on_action_level_id", using: :btree
  add_index "trails", ["action_user_id"], name: "index_trails_on_action_user_id", using: :btree
  add_index "trails", ["action_user_role_id"], name: "index_trails_on_action_user_role_id", using: :btree
  add_index "trails", ["modified_level_id"], name: "index_trails_on_modified_level_id", using: :btree
  add_index "trails", ["parent_type", "parent_id"], name: "index_trails_on_parent_type_and_parent_id", using: :btree

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

  create_table "travel_members", force: :cascade do |t|
    t.string   "title",              limit: 255
    t.string   "first_name",         limit: 255
    t.string   "middle_name",        limit: 255
    t.string   "last_name",          limit: 255
    t.boolean  "child"
    t.integer  "age",                limit: 4
    t.string   "email",              limit: 255
    t.string   "mobile_number",      limit: 255
    t.integer  "booking_id",         limit: 4
    t.integer  "booking_request_id", limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "gender",             limit: 255
  end

  add_index "travel_members", ["booking_id"], name: "index_travel_members_on_booking_id", using: :btree
  add_index "travel_members", ["booking_request_id"], name: "index_travel_members_on_booking_request_id", using: :btree

  create_table "travel_request_comment_actions", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "travel_request_comments", force: :cascade do |t|
    t.integer  "travel_request_id",  limit: 4
    t.text     "content",            limit: 65535
    t.integer  "user_id",            limit: 4
    t.text     "note",               limit: 65535
    t.text     "previous_value",     limit: 65535
    t.text     "new_value",          limit: 65535
    t.text     "edited_field",       limit: 65535
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "action_id",          limit: 4
    t.integer  "booking_id",         limit: 4
    t.integer  "booking_request_id", limit: 4
    t.boolean  "is_deleted",                       default: false
  end

  add_index "travel_request_comments", ["travel_request_id"], name: "index_travel_request_comments_on_travel_request_id", using: :btree
  add_index "travel_request_comments", ["user_id"], name: "index_travel_request_comments_on_user_id", using: :btree

  create_table "travel_request_destinations", force: :cascade do |t|
    t.integer  "travel_request_id", limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "location_id",       limit: 4
  end

  add_index "travel_request_destinations", ["travel_request_id"], name: "index_travel_request_destinations_on_travel_request_id", using: :btree

  create_table "travel_request_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "travel_request_trail_actions", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "travel_request_trails", force: :cascade do |t|
    t.integer  "travel_request_id",       limit: 4
    t.integer  "action_id",               limit: 4
    t.integer  "action_user_id",          limit: 4
    t.integer  "action_user_role_id",     limit: 4
    t.integer  "modified_user_id",        limit: 4
    t.integer  "modified_user_role_id",   limit: 4
    t.integer  "action_for_user_id",      limit: 4
    t.integer  "action_for_user_role_id", limit: 4
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.boolean  "is_deleted",                        default: false
  end

  add_index "travel_request_trails", ["action_for_user_id"], name: "index_travel_request_trails_on_action_for_user_id", using: :btree
  add_index "travel_request_trails", ["action_for_user_role_id"], name: "index_travel_request_trails_on_action_for_user_role_id", using: :btree
  add_index "travel_request_trails", ["action_id"], name: "index_travel_request_trails_on_action_id", using: :btree
  add_index "travel_request_trails", ["action_user_id"], name: "index_travel_request_trails_on_action_user_id", using: :btree
  add_index "travel_request_trails", ["action_user_role_id"], name: "index_travel_request_trails_on_action_user_role_id", using: :btree
  add_index "travel_request_trails", ["modified_user_id"], name: "index_travel_request_trails_on_modified_user_id", using: :btree
  add_index "travel_request_trails", ["modified_user_role_id"], name: "index_travel_request_trails_on_modified_user_role_id", using: :btree
  add_index "travel_request_trails", ["travel_request_id"], name: "index_travel_request_trails_on_travel_request_id", using: :btree

  create_table "travel_requests", force: :cascade do |t|
    t.integer  "user_id",                      limit: 4
    t.integer  "policy_id",                    limit: 4
    t.string   "name",                         limit: 255
    t.text     "note",                         limit: 65535
    t.integer  "status_id",                    limit: 4,                                   null: false
    t.integer  "controlling_user_id",          limit: 4
    t.integer  "controlling_user_role_id",     limit: 4
    t.integer  "controlling_for_user_id",      limit: 4
    t.integer  "controlling_for_user_role_id", limit: 4
    t.datetime "submitted_at",                               precision: 6
    t.datetime "created_at",                                                               null: false
    t.datetime "updated_at",                                                               null: false
    t.integer  "company_id",                   limit: 4
    t.boolean  "is_deleted",                                               default: false
    t.text     "rejection_note",               limit: 65535
    t.boolean  "auto_approved"
    t.text     "memo",                         limit: 65535
    t.date     "from_date"
    t.date     "to_date"
    t.string   "trip_id",                      limit: 255
    t.text     "purpose_of_travel",            limit: 65535
    t.datetime "approved_at"
    t.datetime "selection_requested_at"
    t.datetime "booking_confirmed_at"
  end

  add_index "travel_requests", ["company_id"], name: "index_travel_requests_on_company_id", using: :btree
  add_index "travel_requests", ["controlling_for_user_id"], name: "index_travel_requests_on_controlling_for_user_id", using: :btree
  add_index "travel_requests", ["controlling_for_user_role_id"], name: "index_travel_requests_on_controlling_for_user_role_id", using: :btree
  add_index "travel_requests", ["controlling_user_id"], name: "index_travel_requests_on_controlling_user_id", using: :btree
  add_index "travel_requests", ["controlling_user_role_id"], name: "index_travel_requests_on_controlling_user_role_id", using: :btree
  add_index "travel_requests", ["policy_id"], name: "index_travel_requests_on_policy_id", using: :btree
  add_index "travel_requests", ["status_id"], name: "index_travel_requests_on_status_id", using: :btree
  add_index "travel_requests", ["user_id"], name: "index_travel_requests_on_user_id", using: :btree

  create_table "unique_identifiers", force: :cascade do |t|
    t.string   "prefix",         limit: 255, null: false
    t.string   "sequence_start", limit: 255, null: false
    t.integer  "purpose_id",     limit: 4,   null: false
    t.integer  "company_id",     limit: 4,   null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "unique_identifiers", ["company_id"], name: "index_unique_identifiers_on_company_id", using: :btree
  add_index "unique_identifiers", ["purpose_id"], name: "index_unique_identifiers_on_purpose_id", using: :btree

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

  create_table "user_department_mappings", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.integer  "department_id", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "user_department_mappings", ["department_id"], name: "index_user_department_mappings_on_department_id", using: :btree
  add_index "user_department_mappings", ["user_id"], name: "index_user_department_mappings_on_user_id", using: :btree

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
    t.string   "name",        limit: 255,                 null: false
    t.integer  "company_id",  limit: 4,                   null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.boolean  "is_deleted",              default: false
    t.string   "application", limit: 255
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
    t.integer  "user_id",                            limit: 4
    t.integer  "manager_id",                         limit: 4
    t.integer  "finance_manager_id",                 limit: 4
    t.integer  "approves_to_id",                     limit: 4
    t.integer  "approves_finance_to_id",             limit: 4
    t.integer  "greater_than_amount_id",             limit: 4
    t.boolean  "default",                                      default: false, null: false
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.integer  "policy_id",                          limit: 4,                 null: false
    t.integer  "purpose_id",                         limit: 4
    t.integer  "travel_manager_id",                  limit: 4
    t.boolean  "manager_violation_only"
    t.boolean  "finance_violation_only"
    t.integer  "travel_booking_selector_id",         limit: 4
    t.integer  "travel_booking_approves_to_id",      limit: 4
    t.integer  "travel_approves_to_id",              limit: 4
    t.boolean  "approves_to_violation_only",                   default: false
    t.boolean  "approves_finance_to_violation_only",           default: false
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
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.boolean  "yes_bank_account_transfer"
    t.boolean  "invoicing_system",                    default: false
    t.boolean  "travel_request",                      default: false
  end

  add_index "user_panel_subscriptions", ["user_id"], name: "index_user_panel_subscriptions_on_user_id", using: :btree

  create_table "user_permissions", force: :cascade do |t|
    t.integer  "user_id",              limit: 4
    t.integer  "company_id",           limit: 4
    t.boolean  "create_beneficiaries"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.boolean  "edit_terms_within_po",           default: false
  end

  add_index "user_permissions", ["company_id"], name: "index_user_permissions_on_company_id", using: :btree
  add_index "user_permissions", ["user_id"], name: "index_user_permissions_on_user_id", using: :btree

  create_table "user_pocket_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "user_pockets", force: :cascade do |t|
    t.string   "name",                       limit: 255
    t.integer  "balance_id",                 limit: 4
    t.integer  "user_pocket_type_id",        limit: 4
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.string   "account_code",               limit: 255
    t.boolean  "atm_withdrawal_pocket",                  default: false
    t.integer  "user_id",                    limit: 4
    t.integer  "base_currency_id",           limit: 4
    t.integer  "company_pocket_template_id", limit: 4
  end

  add_index "user_pockets", ["balance_id"], name: "index_user_pockets_on_balance_id", using: :btree
  add_index "user_pockets", ["user_pocket_type_id"], name: "index_user_pockets_on_user_pocket_type_id", using: :btree

  create_table "user_profiles", force: :cascade do |t|
    t.integer  "user_id",                limit: 4
    t.string   "avatar_file_name",       limit: 255
    t.string   "avatar_content_type",    limit: 255
    t.integer  "avatar_file_size",       limit: 4
    t.datetime "avatar_updated_at"
    t.boolean  "kyc_verified"
    t.string   "gcm_sender_id",          limit: 255
    t.string   "employee_id",            limit: 255
    t.string   "payroll_id",             limit: 255
    t.integer  "default_currency_id",    limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.date     "date_of_birth"
    t.string   "gender",                 limit: 255
    t.string   "address_1",              limit: 255
    t.string   "address_2",              limit: 255
    t.string   "city",                   limit: 255
    t.integer  "state_id",               limit: 4
    t.string   "pin_code",               limit: 255
    t.string   "signature_file_name",    limit: 255
    t.string   "signature_content_type", limit: 255
    t.integer  "signature_file_size",    limit: 4
    t.datetime "signature_updated_at"
    t.string   "signature_title",        limit: 255
  end

  add_index "user_profiles", ["default_currency_id"], name: "index_user_profiles_on_default_currency_id", using: :btree
  add_index "user_profiles", ["state_id"], name: "fk_rails_9207fd1f96", using: :btree
  add_index "user_profiles", ["user_id"], name: "index_user_profiles_on_user_id", using: :btree

  create_table "user_role_mappings", force: :cascade do |t|
    t.integer  "user_id",               limit: 4, null: false
    t.integer  "user_role_id",          limit: 4, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "purpose_id",            limit: 4
    t.integer  "company_department_id", limit: 4
    t.integer  "branch_location_id",    limit: 4
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
    t.integer  "company_id",  limit: 4,   null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "name",        limit: 255, null: false
    t.string   "application", limit: 255
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
    t.string   "email",                  limit: 255,   default: ""
    t.string   "encrypted_password",     limit: 255,   default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.integer  "failed_attempts",        limit: 4,     default: 0,     null: false
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "company_id",             limit: 4,                     null: false
    t.string   "mobile_number",          limit: 255
    t.boolean  "active",                               default: true,  null: false
    t.string   "invitation_token",       limit: 255
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit",       limit: 4
    t.integer  "invited_by_id",          limit: 4
    t.string   "invited_by_type",        limit: 255
    t.integer  "invitations_count",      limit: 4,     default: 0
    t.string   "otp",                    limit: 255
    t.datetime "otp_sent_at"
    t.datetime "otp_verified_at"
    t.boolean  "otp_verified",                         default: false, null: false
    t.integer  "otp_count",              limit: 4,     default: 0,     null: false
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.boolean  "mobile_only_invite",                   default: false
    t.string   "mothers_maiden_name",    limit: 255
    t.boolean  "verified",                             default: false
    t.integer  "otp_request_type_id",    limit: 4
    t.boolean  "default_password",                     default: false
    t.boolean  "point_of_contact",                     default: false
    t.integer  "otp_attempts",           limit: 4,     default: 0
    t.integer  "user_delegate_id",       limit: 4
    t.boolean  "delegation_enabled"
    t.text     "gl_config",              limit: 65535
  end

  add_index "users", ["company_id"], name: "index_users_on_company_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "vehicle_rates", force: :cascade do |t|
    t.string   "vehicle_name",     limit: 255,                 null: false
    t.integer  "rate_id",          limit: 4,                   null: false
    t.integer  "distance_unit_id", limit: 4,                   null: false
    t.integer  "policy_id",        limit: 4
    t.boolean  "is_deleted",                   default: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "vehicle_rates", ["distance_unit_id"], name: "index_vehicle_rates_on_distance_unit_id", using: :btree
  add_index "vehicle_rates", ["is_deleted"], name: "index_vehicle_rates_on_is_deleted", using: :btree
  add_index "vehicle_rates", ["policy_id"], name: "index_vehicle_rates_on_policy_id", using: :btree
  add_index "vehicle_rates", ["rate_id"], name: "index_vehicle_rates_on_rate_id", using: :btree

  create_table "vendor_account_transactions", force: :cascade do |t|
    t.integer  "vendor_account_id",   limit: 4
    t.integer  "transaction_type_id", limit: 4
    t.integer  "amount_id",           limit: 4
    t.integer  "payment_id",          limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "vendor_account_transactions", ["amount_id"], name: "index_vendor_account_transactions_on_amount_id", using: :btree
  add_index "vendor_account_transactions", ["payment_id"], name: "index_vendor_account_transactions_on_payment_id", using: :btree
  add_index "vendor_account_transactions", ["transaction_type_id"], name: "index_vendor_account_transactions_on_transaction_type_id", using: :btree
  add_index "vendor_account_transactions", ["vendor_account_id"], name: "index_vendor_account_transactions_on_vendor_account_id", using: :btree

  create_table "vendor_accounts", force: :cascade do |t|
    t.integer  "balance_id", limit: 4
    t.integer  "vendor_id",  limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "vendor_accounts", ["balance_id"], name: "index_vendor_accounts_on_balance_id", using: :btree
  add_index "vendor_accounts", ["vendor_id"], name: "index_vendor_accounts_on_vendor_id", using: :btree

  create_table "vendor_attachments", force: :cascade do |t|
    t.string   "attached_file_file_name",    limit: 255
    t.string   "attached_file_content_type", limit: 255
    t.integer  "attached_file_file_size",    limit: 4
    t.datetime "attached_file_updated_at"
    t.text     "description",                limit: 65535
    t.integer  "yes_bank_vendor_id",         limit: 4
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "attachment_type",            limit: 255
  end

  add_index "vendor_attachments", ["yes_bank_vendor_id"], name: "index_vendor_attachments_on_yes_bank_vendor_id", using: :btree

  create_table "vendor_payment_wallets", force: :cascade do |t|
    t.integer  "balance_id", limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "vendor_payment_wallets", ["balance_id"], name: "index_vendor_payment_wallets_on_balance_id", using: :btree
  add_index "vendor_payment_wallets", ["user_id"], name: "index_vendor_payment_wallets_on_user_id", using: :btree

  create_table "vendor_types", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.integer  "company_id",  limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "vendor_types", ["company_id"], name: "index_vendor_types_on_company_id", using: :btree

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

  create_table "virtual_account_collect_trails", force: :cascade do |t|
    t.boolean  "found_virtual_account"
    t.boolean  "update_company_balance"
    t.boolean  "create_payment"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "account_transaction_id", limit: 4
    t.text     "note",                   limit: 65535
  end

  create_table "virtual_account_purposes", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "virtual_account_transactions", force: :cascade do |t|
    t.string   "beneficiary_account_ifsc",   limit: 255
    t.string   "transfer_type",              limit: 255
    t.string   "beneficiary_full_name",      limit: 255
    t.string   "transfer_id",                limit: 255
    t.string   "transfer_timestamp",         limit: 255
    t.string   "transfer_currency",          limit: 255
    t.string   "transfer_amount",            limit: 255
    t.string   "remitter_account_no",        limit: 255
    t.string   "remitter_account_ifsc",      limit: 255
    t.string   "remitter_account_type",      limit: 255
    t.string   "remitter_full_name",         limit: 255
    t.string   "remitter_address",           limit: 255
    t.string   "note",                       limit: 255
    t.string   "credited_at",                limit: 255
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "virtual_account_id",         limit: 4
    t.boolean  "processed"
    t.boolean  "receiving_account_credited"
    t.string   "beneficiary_account_no",     limit: 255
  end

  create_table "virtual_bank_accounts", force: :cascade do |t|
    t.string   "account_number",                limit: 255
    t.string   "ifsc",                          limit: 255
    t.text     "description",                   limit: 65535
    t.integer  "parent_id",                     limit: 4
    t.string   "parent_type",                   limit: 255
    t.integer  "company_id",                    limit: 4
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.date     "expires_by"
    t.integer  "purpose_id",                    limit: 4
    t.boolean  "active",                                      default: true
    t.boolean  "is_deleted",                                  default: false
    t.integer  "initiating_user_id",            limit: 4
    t.string   "name",                          limit: 255
    t.integer  "receiving_account_id",          limit: 4
    t.string   "receiving_account_type",        limit: 255
    t.integer  "maximum_transaction_amount_id", limit: 4
    t.integer  "minimum_transaction_amount_id", limit: 4
    t.integer  "allowed_transaction_count",     limit: 4
    t.boolean  "neft",                                        default: true
    t.boolean  "imps",                                        default: true
    t.boolean  "rtgs",                                        default: true
    t.boolean  "current_account",                             default: true
    t.boolean  "savings_account",                             default: true
    t.boolean  "upi",                                         default: true
    t.date     "active_after"
    t.date     "active_on"
    t.integer  "maximum_amount_id",             limit: 4
    t.integer  "exact_transaction_amount_id",   limit: 4
    t.string   "application",                   limit: 255,                   null: false
    t.integer  "customer_id",                   limit: 4
    t.boolean  "default_account"
  end

  create_table "web_hook_event_mappings", force: :cascade do |t|
    t.integer  "web_hook_id",       limit: 4,                 null: false
    t.integer  "web_hook_event_id", limit: 4,                 null: false
    t.boolean  "is_deleted",                  default: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "web_hook_event_mappings", ["is_deleted"], name: "index_web_hook_event_mappings_on_is_deleted", using: :btree
  add_index "web_hook_event_mappings", ["web_hook_event_id"], name: "index_web_hook_event_mappings_on_web_hook_event_id", using: :btree
  add_index "web_hook_event_mappings", ["web_hook_id"], name: "index_web_hook_event_mappings_on_web_hook_id", using: :btree

  create_table "web_hook_events", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "web_hook_events", ["name"], name: "index_web_hook_events_on_name", using: :btree

  create_table "web_hook_tracks", force: :cascade do |t|
    t.integer  "web_hook_id",       limit: 4
    t.integer  "web_hook_event_id", limit: 4
    t.integer  "company_id",        limit: 4
    t.text     "url",               limit: 65535
    t.text     "request_body",      limit: 65535
    t.text     "request_header",    limit: 65535
    t.decimal  "response_time",                      precision: 10
    t.text     "response_body",     limit: 16777215
    t.integer  "response_status",   limit: 4
    t.integer  "attempt",           limit: 4
    t.datetime "last_attempted_at"
    t.boolean  "attempt_success"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  add_index "web_hook_tracks", ["company_id"], name: "index_web_hook_tracks_on_company_id", using: :btree
  add_index "web_hook_tracks", ["web_hook_event_id"], name: "index_web_hook_tracks_on_web_hook_event_id", using: :btree
  add_index "web_hook_tracks", ["web_hook_id"], name: "index_web_hook_tracks_on_web_hook_id", using: :btree

  create_table "web_hooks", force: :cascade do |t|
    t.text     "url",                limit: 65535,                 null: false
    t.string   "secret",             limit: 255
    t.integer  "created_by_user_id", limit: 4,                     null: false
    t.integer  "company_id",         limit: 4,                     null: false
    t.boolean  "is_deleted",                       default: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.text     "headers",            limit: 65535
  end

  add_index "web_hooks", ["company_id"], name: "index_web_hooks_on_company_id", using: :btree
  add_index "web_hooks", ["created_by_user_id"], name: "index_web_hooks_on_created_by_user_id", using: :btree
  add_index "web_hooks", ["is_deleted"], name: "index_web_hooks_on_is_deleted", using: :btree

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

  create_table "yes_bank_configurations", force: :cascade do |t|
    t.boolean  "custom_bank_account",            default: false
    t.integer  "company_id",           limit: 4
    t.boolean  "yes_bank_api_enabled",           default: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  create_table "yes_bank_vendors", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.integer  "company_id",        limit: 4
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "email",             limit: 255
    t.string   "mobile_number",     limit: 255
    t.boolean  "authorized"
    t.text     "description",       limit: 65535
    t.boolean  "is_deleted",                      default: false
    t.string   "pan",               limit: 255
    t.string   "tin",               limit: 255
    t.string   "gst",               limit: 255
    t.boolean  "gst_registered"
    t.string   "state",             limit: 255
    t.integer  "state_code_id",     limit: 4
    t.integer  "created_by_id",     limit: 4
    t.integer  "vendor_type_id",    limit: 4
    t.string   "address",           limit: 255
    t.string   "business_name",     limit: 255
    t.integer  "payment_term_id",   limit: 4
    t.integer  "currency_id",       limit: 4
    t.integer  "tds_rates_list_id", limit: 4
  end

  add_index "yes_bank_vendors", ["company_id"], name: "index_yes_bank_vendors_on_company_id", using: :btree
  add_index "yes_bank_vendors", ["tds_rates_list_id"], name: "index_yes_bank_vendors_on_tds_rates_list_id", using: :btree
  add_index "yes_bank_vendors", ["vendor_type_id"], name: "index_yes_bank_vendors_on_vendor_type_id", using: :btree

  add_foreign_key "accounting_system_configurations", "companies"
  add_foreign_key "addresses", "states"
  add_foreign_key "admin_review_workflow_levels", "admin_review_workflows"
  add_foreign_key "admin_summary_mail_configs", "periods"
  add_foreign_key "admin_summary_mail_configs", "users"
  add_foreign_key "admin_user_role_mappings", "admin_user_roles"
  add_foreign_key "admin_user_role_mappings", "admin_users"
  add_foreign_key "agreements", "agreement_types"
  add_foreign_key "amounts", "currencies"
  add_foreign_key "approval_routes", "policies"
  add_foreign_key "approval_routes", "purposes"
  add_foreign_key "approval_routes", "users"
  add_foreign_key "authentications", "users"
  add_foreign_key "auto_submit_configs", "periods"
  add_foreign_key "auto_sync_configs", "auto_sync_config_types"
  add_foreign_key "auto_sync_configs", "companies"
  add_foreign_key "auto_sync_configs", "periods"
  add_foreign_key "balance_sheets", "users"
  add_foreign_key "bank_accounts", "yes_bank_vendors"
  add_foreign_key "bank_payment_request_comments", "users"
  add_foreign_key "bank_payment_request_trails", "bank_payment_requests"
  add_foreign_key "bank_transactions", "amounts"
  add_foreign_key "bank_transactions", "companies"
  add_foreign_key "bill_of_supplies", "companies"
  add_foreign_key "bill_of_supplies", "document_statuses"
  add_foreign_key "bill_of_supplies", "payment_terms"
  add_foreign_key "bill_of_supplies", "procurement_terms"
  add_foreign_key "bill_of_supplies", "procurements"
  add_foreign_key "bill_of_supplies", "users"
  add_foreign_key "booking_attachments", "bookings"
  add_foreign_key "booking_attachments", "companies"
  add_foreign_key "booking_attachments", "users"
  add_foreign_key "booking_requests", "booking_statuses"
  add_foreign_key "booking_requests", "booking_types"
  add_foreign_key "bookings", "booking_requests"
  add_foreign_key "bookings", "booking_statuses"
  add_foreign_key "bookings", "booking_types"
  add_foreign_key "branch_locations", "companies"
  add_foreign_key "branch_locations", "states"
  add_foreign_key "budget_criteria_mappings", "budgets"
  add_foreign_key "budget_rule_category_mappings", "budget_rules"
  add_foreign_key "budget_rule_category_mappings", "categories"
  add_foreign_key "budget_rule_field_mappings", "budget_rules"
  add_foreign_key "budget_rule_field_mappings", "field_configurations"
  add_foreign_key "budget_rule_field_mappings", "field_drop_down_items"
  add_foreign_key "budget_rules", "amounts"
  add_foreign_key "budget_rules", "categories"
  add_foreign_key "budget_rules", "periods"
  add_foreign_key "budget_rules", "policies"
  add_foreign_key "budget_rules", "rule_types"
  add_foreign_key "budgets", "companies"
  add_foreign_key "budgets", "periods"
  add_foreign_key "budgets", "users"
  add_foreign_key "callback_tracks", "companies"
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
  add_foreign_key "collect_company_details", "companies"
  add_foreign_key "company_accounts", "companies"
  add_foreign_key "company_accounts", "company_account_types"
  add_foreign_key "company_agreement_tracks", "agreements"
  add_foreign_key "company_agreement_tracks", "users"
  add_foreign_key "company_balance_histories", "companies"
  add_foreign_key "company_branches", "collect_company_details"
  add_foreign_key "company_branches", "companies"
  add_foreign_key "company_configurations", "companies"
  add_foreign_key "company_configurations", "contacts"
  add_foreign_key "company_departments", "companies"
  add_foreign_key "company_funds_auto_transfer_configs", "companies"
  add_foreign_key "company_funds_load_requests", "amounts"
  add_foreign_key "company_funds_load_requests", "companies"
  add_foreign_key "company_kyc_trails", "company_kycs"
  add_foreign_key "company_kycs", "companies"
  add_foreign_key "company_location_departments", "branch_locations"
  add_foreign_key "company_location_departments", "company_departments"
  add_foreign_key "company_pocket_templates", "companies"
  add_foreign_key "company_pocket_templates", "user_pocket_types"
  add_foreign_key "company_tags", "companies"
  add_foreign_key "cost_centers", "companies"
  add_foreign_key "custom_fields", "field_configurations"
  add_foreign_key "customer_account_transactions", "customer_accounts"
  add_foreign_key "customer_accounts", "customers"
  add_foreign_key "customer_attachments", "customers"
  add_foreign_key "delivery_challans", "companies"
  add_foreign_key "delivery_challans", "document_statuses"
  add_foreign_key "delivery_challans", "payment_terms"
  add_foreign_key "delivery_challans", "procurement_terms"
  add_foreign_key "delivery_challans", "procurements"
  add_foreign_key "delivery_challans", "users"
  add_foreign_key "departments", "companies"
  add_foreign_key "departments", "cost_centers"
  add_foreign_key "distance_expenses", "expenses"
  add_foreign_key "distances", "physical_units"
  add_foreign_key "document_items", "inventory_line_items"
  add_foreign_key "document_items", "purchase_order_items"
  add_foreign_key "document_level_reviewer_mappings", "policies"
  add_foreign_key "document_number_configs", "companies"
  add_foreign_key "document_number_configs", "document_number_config_types"
  add_foreign_key "document_number_configs", "purposes"
  add_foreign_key "e_way_bills", "amounts"
  add_foreign_key "e_way_bills", "companies"
  add_foreign_key "e_way_bills", "payment_terms"
  add_foreign_key "e_way_bills", "procurement_terms"
  add_foreign_key "e_way_bills", "procurements"
  add_foreign_key "e_way_bills", "users"
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
  add_foreign_key "expenses", "expense_tax_types"
  add_foreign_key "expenses", "expense_types"
  add_foreign_key "expenses", "reports"
  add_foreign_key "expenses", "users"
  add_foreign_key "export_configs", "companies"
  add_foreign_key "export_configs", "export_config_types"
  add_foreign_key "export_preferences", "companies"
  add_foreign_key "export_preferences", "export_fields"
  add_foreign_key "feedbacks", "feedback_types"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "field_configurations", "companies"
  add_foreign_key "field_configurations", "field_types"
  add_foreign_key "field_drop_down_items", "field_configurations"
  add_foreign_key "field_parent_mappings", "field_configurations"
  add_foreign_key "field_parent_mappings", "field_parent_types"
  add_foreign_key "finly_transactions", "amounts"
  add_foreign_key "finly_transactions", "companies"
  add_foreign_key "finly_transactions", "payment_purposes"
  add_foreign_key "finly_transactions", "payments"
  add_foreign_key "finly_transactions", "transaction_types"
  add_foreign_key "individual_kyc_tracks", "individual_kycs"
  add_foreign_key "individual_kycs", "admin_review_workflows"
  add_foreign_key "individual_kycs", "companies"
  add_foreign_key "individual_kycs", "users"
  add_foreign_key "inventory_line_items", "categories"
  add_foreign_key "inventory_line_items", "companies"
  add_foreign_key "inventory_line_items", "tax_rates"
  add_foreign_key "invoice_attachments", "invoices"
  add_foreign_key "invoice_line_items", "categories"
  add_foreign_key "invoice_line_items", "invoices"
  add_foreign_key "invoice_number_configs", "invoice_number_config_types"
  add_foreign_key "invoice_number_configs", "purposes"
  add_foreign_key "invoices", "addresses"
  add_foreign_key "invoices", "payment_terms"
  add_foreign_key "inward_document_items", "inventory_line_items"
  add_foreign_key "inward_document_items", "inward_documents"
  add_foreign_key "inward_document_items", "purchase_order_items"
  add_foreign_key "inward_documents", "companies"
  add_foreign_key "inward_documents", "procurements"
  add_foreign_key "inward_documents", "users"
  add_foreign_key "itz_cash_company_accounts", "companies"
  add_foreign_key "itz_cash_dmt_beneficiaries", "itz_cash_dmt_senders"
  add_foreign_key "itz_cash_dmt_senders", "users"
  add_foreign_key "itz_cash_properties", "companies"
  add_foreign_key "kyc_documents", "company_kyc_document_types"
  add_foreign_key "kyc_documents", "company_kycs"
  add_foreign_key "login_agreement_mappings", "agreements"
  add_foreign_key "login_agreement_mappings", "users"
  add_foreign_key "manager_summary_mail_configs", "periods"
  add_foreign_key "manager_summary_mail_configs", "users"
  add_foreign_key "manual_expenses", "expenses"
  add_foreign_key "mcc_category_mappings", "categories"
  add_foreign_key "money_request_comments", "expenses"
  add_foreign_key "money_request_comments", "money_requests"
  add_foreign_key "money_request_comments", "payments"
  add_foreign_key "money_request_comments", "users"
  add_foreign_key "money_request_item_categories", "companies"
  add_foreign_key "money_request_items", "amounts"
  add_foreign_key "money_request_items", "categories"
  add_foreign_key "money_request_items", "money_requests"
  add_foreign_key "money_request_processor_mappings", "amounts"
  add_foreign_key "money_request_processor_mappings", "payments"
  add_foreign_key "money_request_processor_mappings", "users"
  add_foreign_key "money_request_processors", "companies"
  add_foreign_key "money_request_processors", "payment_orders"
  add_foreign_key "money_request_tracks", "money_request_tracking_actions"
  add_foreign_key "money_request_tracks", "money_requests"
  add_foreign_key "money_request_tracks", "payments"
  add_foreign_key "money_requests", "payment_modes"
  add_foreign_key "money_requests", "payments"
  add_foreign_key "money_requests", "policies"
  add_foreign_key "money_requests", "travel_requests"
  add_foreign_key "money_requests", "users"
  add_foreign_key "new_card_requests", "card_types"
  add_foreign_key "new_card_requests", "companies"
  add_foreign_key "notifications", "notification_types"
  add_foreign_key "notifications", "users"
  add_foreign_key "notifier_type_configurations", "notifier_types", column: "event_id"
  add_foreign_key "notifier_type_configurations", "users"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "outward_invoice_attachments", "companies"
  add_foreign_key "outward_invoice_attachments", "outward_invoices"
  add_foreign_key "outward_invoice_attachments", "users"
  add_foreign_key "outward_invoice_trails", "amounts"
  add_foreign_key "outward_invoice_trails", "outward_invoices"
  add_foreign_key "outward_invoice_trails", "users"
  add_foreign_key "outward_invoices", "amounts"
  add_foreign_key "outward_invoices", "customers"
  add_foreign_key "outward_invoices", "locations"
  add_foreign_key "outward_invoices", "outward_invoice_types"
  add_foreign_key "outward_invoices", "payment_terms"
  add_foreign_key "outward_invoices", "users"
  add_foreign_key "payment_file_configurations", "companies"
  add_foreign_key "payment_orders", "companies"
  add_foreign_key "payment_orders", "payment_order_statuses"
  add_foreign_key "payment_receivables", "amounts"
  add_foreign_key "payment_receivables", "companies"
  add_foreign_key "payment_receivables", "customers"
  add_foreign_key "payment_receivables", "payment_receivable_statuses"
  add_foreign_key "payments", "amounts"
  add_foreign_key "payments", "categories"
  add_foreign_key "payments", "payment_types"
  add_foreign_key "per_diem_expenses", "expenses"
  add_foreign_key "per_diem_expenses", "per_diems"
  add_foreign_key "policies", "companies"
  add_foreign_key "policy_configurations", "policies"
  add_foreign_key "policy_field_mappings", "field_configurations"
  add_foreign_key "policy_field_mappings", "policies"
  add_foreign_key "policy_user_mappings", "policies"
  add_foreign_key "policy_user_mappings", "users"
  add_foreign_key "policy_user_roles", "policies"
  add_foreign_key "policy_user_roles", "user_roles"
  add_foreign_key "policy_user_roles", "users"
  add_foreign_key "procurement_charges", "amounts"
  add_foreign_key "procurement_comments", "users"
  add_foreign_key "procurement_status_taggables", "procurements"
  add_foreign_key "procurement_status_taggables", "status_tags"
  add_foreign_key "procurement_terms", "companies"
  add_foreign_key "procurements", "companies"
  add_foreign_key "procurements", "procurement_statuses"
  add_foreign_key "procurements", "procurement_tracks"
  add_foreign_key "procurements", "users"
  add_foreign_key "purchase_order_items", "inventory_line_items"
  add_foreign_key "purchase_order_items", "purchase_orders"
  add_foreign_key "purchase_orders", "companies"
  add_foreign_key "purchase_orders", "gst_types"
  add_foreign_key "purchase_orders", "payment_terms"
  add_foreign_key "purchase_orders", "policies"
  add_foreign_key "purchase_orders", "procurement_terms"
  add_foreign_key "purchase_orders", "procurements"
  add_foreign_key "purchase_orders", "purchase_order_statuses"
  add_foreign_key "purchase_orders", "users"
  add_foreign_key "quickbooks_configurations", "quickbooks_payment_types"
  add_foreign_key "quickbooks_configurations", "users"
  add_foreign_key "quickbooks_departments", "companies"
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
  add_foreign_key "report_processor_group_mappings", "amounts"
  add_foreign_key "report_processor_group_mappings", "payments"
  add_foreign_key "report_processor_group_mappings", "users"
  add_foreign_key "report_processor_groups", "companies"
  add_foreign_key "report_processor_groups", "payment_orders"
  add_foreign_key "report_tracks", "report_statuses"
  add_foreign_key "report_tracks", "report_tracking_actions"
  add_foreign_key "report_tracks", "reports"
  add_foreign_key "reports", "policies"
  add_foreign_key "reports", "report_processor_group_mappings"
  add_foreign_key "reports", "report_statuses"
  add_foreign_key "reports", "users"
  add_foreign_key "resource_templates", "users"
  add_foreign_key "reviewal_levels", "policies"
  add_foreign_key "tally_configurations", "companies"
  add_foreign_key "tax_rates", "companies"
  add_foreign_key "time_expenses", "expenses"
  add_foreign_key "time_objects", "physical_units"
  add_foreign_key "transcribed_expenses", "amounts"
  add_foreign_key "transcribed_expenses", "expenses"
  add_foreign_key "transcribed_expenses", "receipts"
  add_foreign_key "transcribed_expenses", "users"
  add_foreign_key "travel_members", "booking_requests"
  add_foreign_key "travel_members", "bookings"
  add_foreign_key "travel_request_comments", "travel_requests"
  add_foreign_key "travel_request_comments", "users"
  add_foreign_key "travel_request_destinations", "travel_requests"
  add_foreign_key "travel_request_trails", "travel_requests"
  add_foreign_key "travel_requests", "policies"
  add_foreign_key "travel_requests", "users"
  add_foreign_key "unique_identifiers", "companies"
  add_foreign_key "unique_identifiers", "purposes"
  add_foreign_key "user_balance_histories", "companies"
  add_foreign_key "user_balance_histories", "users"
  add_foreign_key "user_department_mappings", "departments"
  add_foreign_key "user_department_mappings", "users"
  add_foreign_key "user_group_item_mappings", "user_group_items"
  add_foreign_key "user_group_item_mappings", "user_groups"
  add_foreign_key "user_group_item_mappings", "users"
  add_foreign_key "user_group_items", "user_groups"
  add_foreign_key "user_groups", "companies"
  add_foreign_key "user_login_tracks", "users"
  add_foreign_key "user_manager_mappings", "policies"
  add_foreign_key "user_manager_mappings", "users"
  add_foreign_key "user_panel_subscriptions", "users"
  add_foreign_key "user_permissions", "companies"
  add_foreign_key "user_permissions", "users"
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
  add_foreign_key "vehicle_rates", "policies"
  add_foreign_key "vendor_account_transactions", "amounts"
  add_foreign_key "vendor_account_transactions", "payments"
  add_foreign_key "vendor_account_transactions", "vendor_accounts"
  add_foreign_key "vendor_payment_wallets", "users"
  add_foreign_key "vendor_types", "companies"
  add_foreign_key "web_hook_event_mappings", "web_hook_events"
  add_foreign_key "web_hook_event_mappings", "web_hooks"
  add_foreign_key "web_hook_tracks", "companies"
  add_foreign_key "web_hook_tracks", "web_hook_events"
  add_foreign_key "web_hook_tracks", "web_hooks"
  add_foreign_key "whitelisted_ips", "companies"
  add_foreign_key "yes_bank_company_accounts", "companies"
  add_foreign_key "yes_bank_vendors", "companies"
  add_foreign_key "yes_bank_vendors", "tds_rates_lists"
  add_foreign_key "yes_bank_vendors", "vendor_types"
end
