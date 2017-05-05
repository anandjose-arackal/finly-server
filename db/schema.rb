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

ActiveRecord::Schema.define(version: 20170505131820) do

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
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "amounts", force: :cascade do |t|
    t.decimal  "value",                 precision: 64, scale: 12
    t.integer  "currency_id", limit: 4,                           null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "amounts", ["currency_id"], name: "index_amounts_on_currency_id", using: :btree

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
    t.string   "ending_number",            limit: 255,                  null: false
    t.string   "proxy",                    limit: 255,                  null: false
    t.integer  "card_type_id",             limit: 4
    t.text     "description",              limit: 65535
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.integer  "company_id",               limit: 4
    t.integer  "disabled_by_role_id",      limit: 4
    t.integer  "disabled_by_user_id",      limit: 4
    t.boolean  "active"
    t.text     "disable_note",             limit: 65535
    t.integer  "card_balance_id",          limit: 4
    t.integer  "card_program_id",          limit: 4,                    null: false
    t.integer  "card_eligibility_id",      limit: 4
    t.boolean  "admin_unblockable",                      default: true
    t.integer  "itz_cash_card_program_id", limit: 4
  end

  add_index "cards", ["card_type_id"], name: "index_cards_on_card_type_id", using: :btree
  add_index "cards", ["company_id"], name: "index_cards_on_company_id", using: :btree
  add_index "cards", ["user_id"], name: "index_cards_on_user_id", using: :btree

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

  create_table "companies", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "active",                 default: true, null: false
  end

  create_table "company_accounts", force: :cascade do |t|
    t.integer  "company_id",        limit: 4, null: false
    t.integer  "wallet_balance_id", limit: 4
    t.integer  "company",           limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "company_accounts", ["company"], name: "index_company_accounts_on_company", using: :btree
  add_index "company_accounts", ["company_id"], name: "index_company_accounts_on_company_id", using: :btree
  add_index "company_accounts", ["wallet_balance_id"], name: "index_company_accounts_on_wallet_balance_id", using: :btree

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
    t.integer  "company_id",          limit: 4,                   null: false
    t.integer  "contact_id",          limit: 4
    t.boolean  "verified",                        default: false
    t.string   "logo_file_name",      limit: 255
    t.string   "logo_content_type",   limit: 255
    t.integer  "logo_file_size",      limit: 4
    t.datetime "logo_updated_at"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.boolean  "other_expense_types",             default: false
  end

  add_index "company_configurations", ["company_id"], name: "index_company_configurations_on_company_id", using: :btree
  add_index "company_configurations", ["contact_id"], name: "index_company_configurations_on_contact_id", using: :btree

  create_table "company_funds_load_requests", force: :cascade do |t|
    t.integer  "company_id",           limit: 4
    t.integer  "requested_by_user_id", limit: 4,     null: false
    t.string   "reference_id",         limit: 255,   null: false
    t.date     "date",                               null: false
    t.integer  "amount_id",            limit: 4
    t.text     "remark",               limit: 65535
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "company_funds_load_requests", ["amount_id"], name: "index_company_funds_load_requests_on_amount_id", using: :btree
  add_index "company_funds_load_requests", ["company_id"], name: "index_company_funds_load_requests_on_company_id", using: :btree
  add_index "company_funds_load_requests", ["requested_by_user_id"], name: "index_company_funds_load_requests_on_requested_by_user_id", using: :btree

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
    t.string   "job_id",            limit: 255,   null: false
    t.text     "log",               limit: 65535
    t.datetime "last_performed_at"
    t.boolean  "healthy"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
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
    t.integer  "parent_id",           limit: 4
    t.string   "parent_type",         limit: 255
    t.decimal  "rate_per_km",                     precision: 10, scale: 4
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.boolean  "enabled"
    t.integer  "default_category_id", limit: 4
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

  create_table "enforce_policies", force: :cascade do |t|
    t.integer  "enforceable_id",   limit: 4,   null: false
    t.string   "enforceable_type", limit: 255, null: false
    t.boolean  "enabled"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "enforce_policies", ["enforceable_type", "enforceable_id"], name: "index_enforce_policies_on_enforceable_type_and_enforceable_id", using: :btree

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

  create_table "itz_cash_card_programs", force: :cascade do |t|
    t.string   "product_code", limit: 255
    t.string   "charge_code",  limit: 255
    t.string   "name",         limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "bank",         limit: 255
  end

  create_table "itz_cash_properties", force: :cascade do |t|
    t.string   "d_code",          limit: 255
    t.string   "easy_account_no", limit: 255
    t.integer  "company_id",      limit: 4,   null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "itz_cash_properties", ["company_id"], name: "index_itz_cash_properties_on_company_id", using: :btree

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
    t.integer  "policy_id",                    limit: 4
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
    t.integer  "payment_order_type_id",     limit: 4,     null: false
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
  end

  add_index "payment_orders", ["amount_processed_id"], name: "index_payment_orders_on_amount_processed_id", using: :btree
  add_index "payment_orders", ["amount_requested_id"], name: "index_payment_orders_on_amount_requested_id", using: :btree
  add_index "payment_orders", ["company_id"], name: "index_payment_orders_on_company_id", using: :btree
  add_index "payment_orders", ["initiating_user_id"], name: "index_payment_orders_on_initiating_user_id", using: :btree
  add_index "payment_orders", ["payment_order_status_id"], name: "index_payment_orders_on_payment_order_status_id", using: :btree
  add_index "payment_orders", ["payment_order_type_id"], name: "index_payment_orders_on_payment_order_type_id", using: :btree

  create_table "payment_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

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
    t.integer  "receiving_user_id",       limit: 4,     null: false
    t.text     "note",                    limit: 65535
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "initiating_account_id",   limit: 4
    t.string   "initiating_account_type", limit: 255
    t.integer  "receiving_account_id",    limit: 4
    t.string   "receiving_account_type",  limit: 255
    t.integer  "payment_order_id",        limit: 4
    t.integer  "payment_status_id",       limit: 4,     null: false
  end

  add_index "payments", ["amount_id"], name: "index_payments_on_amount_id", using: :btree
  add_index "payments", ["initiating_user_id"], name: "index_payments_on_initiating_user_id", using: :btree
  add_index "payments", ["payment_type_id"], name: "index_payments_on_payment_type_id", using: :btree
  add_index "payments", ["receiving_user_id"], name: "index_payments_on_receiving_user_id", using: :btree

  create_table "per_diem_expense_configs", force: :cascade do |t|
    t.integer  "parent_id",   limit: 4
    t.string   "parent_type", limit: 255
    t.boolean  "enabled"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
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

  create_table "policies", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "company_id",  limit: 4
    t.integer  "owner_id",    limit: 4
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.boolean  "default",                   default: false, null: false
    t.boolean  "is_deleted",                default: false, null: false
    t.text     "description", limit: 65535
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
    t.string   "email",        limit: 255
    t.text     "company",      limit: 65535
    t.string   "phone_number", limit: 255
    t.text     "name",         limit: 65535
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "product_combinations", force: :cascade do |t|
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
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "receipt_email_attachments", ["receipt_email_id"], name: "index_receipt_email_attachments_on_receipt_email_id", using: :btree

  create_table "receipt_emails", force: :cascade do |t|
    t.text     "subject",                 limit: 65535
    t.datetime "sent_at"
    t.integer  "user_id",                 limit: 4
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "body_file_name",          limit: 255
    t.string   "body_content_type",       limit: 255
    t.integer  "body_file_size",          limit: 4
    t.datetime "body_updated_at"
    t.string   "raw_text_file_name",      limit: 255
    t.string   "raw_text_content_type",   limit: 255
    t.integer  "raw_text_file_size",      limit: 4
    t.datetime "raw_text_updated_at"
    t.string   "raw_html_file_name",      limit: 255
    t.string   "raw_html_content_type",   limit: 255
    t.integer  "raw_html_file_size",      limit: 4
    t.datetime "raw_html_updated_at"
    t.string   "raw_header_file_name",    limit: 255
    t.string   "raw_header_content_type", limit: 255
    t.integer  "raw_header_file_size",    limit: 4
    t.datetime "raw_header_updated_at"
  end

  add_index "receipt_emails", ["user_id"], name: "index_receipt_emails_on_user_id", using: :btree

  create_table "receipts", force: :cascade do |t|
    t.integer  "expense_id",         limit: 4
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
  end

  add_index "receipts", ["expense_id"], name: "index_receipts_on_expense_id", using: :btree
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
    t.integer  "policy_id",                          limit: 4
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
  end

  add_index "reports", ["controlling_for_user_id"], name: "index_reports_on_controlling_for_user_id", using: :btree
  add_index "reports", ["controlling_for_user_role_id"], name: "index_reports_on_controlling_for_user_role_id", using: :btree
  add_index "reports", ["controlling_user_id"], name: "index_reports_on_controlling_user_id", using: :btree
  add_index "reports", ["controlling_user_role_id"], name: "index_reports_on_controlling_user_role_id", using: :btree
  add_index "reports", ["policy_id"], name: "index_reports_on_policy_id", using: :btree
  add_index "reports", ["report_status_id"], name: "index_reports_on_report_status_id", using: :btree
  add_index "reports", ["user_id"], name: "index_reports_on_user_id", using: :btree

  create_table "resource_requests", force: :cascade do |t|
    t.string "name",               limit: 255
    t.string "email",              limit: 255
    t.string "mobile_number",      limit: 255
    t.string "resource_file_name", limit: 255
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
  end

  add_index "system_messages", ["system_message_type_id"], name: "index_system_messages_on_system_message_type_id", using: :btree

  create_table "time_expense_configs", force: :cascade do |t|
    t.integer  "parent_id",           limit: 4
    t.string   "parent_type",         limit: 255
    t.decimal  "rate_per_hour",                   precision: 10, scale: 4
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.boolean  "enabled"
    t.integer  "default_category_id", limit: 4
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
    t.integer  "policy_id",              limit: 4
  end

  add_index "user_manager_mappings", ["approves_finance_to_id"], name: "index_user_manager_mappings_on_approves_finance_to_id", using: :btree
  add_index "user_manager_mappings", ["approves_to_id"], name: "index_user_manager_mappings_on_approves_to_id", using: :btree
  add_index "user_manager_mappings", ["finance_manager_id"], name: "index_user_manager_mappings_on_finance_manager_id", using: :btree
  add_index "user_manager_mappings", ["greater_than_amount_id"], name: "index_user_manager_mappings_on_greater_than_amount_id", using: :btree
  add_index "user_manager_mappings", ["manager_id"], name: "index_user_manager_mappings_on_manager_id", using: :btree
  add_index "user_manager_mappings", ["policy_id"], name: "index_user_manager_mappings_on_policy_id", using: :btree
  add_index "user_manager_mappings", ["user_id"], name: "index_user_manager_mappings_on_user_id", using: :btree

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

  add_foreign_key "admin_user_role_mappings", "admin_user_roles"
  add_foreign_key "admin_user_role_mappings", "admin_users"
  add_foreign_key "amounts", "currencies"
  add_foreign_key "auto_submit_configs", "periods"
  add_foreign_key "balance_sheets", "users"
  add_foreign_key "budget_rules", "amounts"
  add_foreign_key "budget_rules", "categories"
  add_foreign_key "budget_rules", "periods"
  add_foreign_key "budget_rules", "policies"
  add_foreign_key "budget_rules", "rule_types"
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
  add_foreign_key "categories", "companies"
  add_foreign_key "company_accounts", "companies"
  add_foreign_key "company_balance_histories", "companies"
  add_foreign_key "company_configurations", "companies"
  add_foreign_key "company_configurations", "contacts"
  add_foreign_key "company_funds_load_requests", "amounts"
  add_foreign_key "company_funds_load_requests", "companies"
  add_foreign_key "company_tags", "companies"
  add_foreign_key "custom_fields", "field_configurations"
  add_foreign_key "distance_expenses", "expenses"
  add_foreign_key "distances", "physical_units"
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
  add_foreign_key "itz_cash_properties", "companies"
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
  add_foreign_key "payment_orders", "companies"
  add_foreign_key "payment_orders", "payment_order_statuses"
  add_foreign_key "payment_orders", "payment_order_types"
  add_foreign_key "payments", "amounts"
  add_foreign_key "payments", "payment_types"
  add_foreign_key "per_diem_expenses", "expenses"
  add_foreign_key "per_diem_expenses", "per_diems"
  add_foreign_key "policies", "companies"
  add_foreign_key "policy_configurations", "policies"
  add_foreign_key "policy_user_mappings", "policies"
  add_foreign_key "policy_user_mappings", "users"
  add_foreign_key "receipts", "expenses"
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
  add_foreign_key "user_manager_mappings", "policies"
  add_foreign_key "user_manager_mappings", "users"
  add_foreign_key "user_profiles", "users"
  add_foreign_key "user_role_mappings", "user_roles"
  add_foreign_key "user_role_mappings", "users"
  add_foreign_key "user_tags", "users"
  add_foreign_key "user_wallet_tracks", "amounts"
  add_foreign_key "user_wallet_tracks", "user_wallet_track_actions"
  add_foreign_key "user_wallet_tracks", "user_wallets"
  add_foreign_key "user_wallets", "users"
  add_foreign_key "users", "companies"
end
