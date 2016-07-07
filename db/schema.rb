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

ActiveRecord::Schema.define(version: 20160707083000) do

  create_table "amounts", force: :cascade do |t|
    t.float    "value",       limit: 24
    t.integer  "currency_id", limit: 4,  null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "amounts", ["currency_id"], name: "index_amounts_on_currency_id", using: :btree

  create_table "budget_periods", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "budget_rules", force: :cascade do |t|
    t.integer  "category_id",      limit: 4
    t.integer  "amount_id",        limit: 4
    t.integer  "budget_period_id", limit: 4
    t.integer  "policy_id",        limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "rule_type_id",     limit: 4
  end

  add_index "budget_rules", ["amount_id"], name: "index_budget_rules_on_amount_id", using: :btree
  add_index "budget_rules", ["budget_period_id"], name: "index_budget_rules_on_budget_period_id", using: :btree
  add_index "budget_rules", ["category_id"], name: "index_budget_rules_on_category_id", using: :btree
  add_index "budget_rules", ["policy_id"], name: "index_budget_rules_on_policy_id", using: :btree
  add_index "budget_rules", ["rule_type_id"], name: "index_budget_rules_on_rule_type_id", using: :btree

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

  create_table "companies", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "active",                 default: true, null: false
  end

  create_table "company_configurations", force: :cascade do |t|
    t.integer  "company_id",        limit: 4,                   null: false
    t.integer  "contact_id",        limit: 4
    t.boolean  "verified",                      default: false
    t.string   "logo_file_name",    limit: 255
    t.string   "logo_content_type", limit: 255
    t.integer  "logo_file_size",    limit: 4
    t.datetime "logo_updated_at"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  add_index "company_configurations", ["company_id"], name: "index_company_configurations_on_company_id", using: :btree
  add_index "company_configurations", ["contact_id"], name: "index_company_configurations_on_contact_id", using: :btree

  create_table "company_tags", force: :cascade do |t|
    t.integer  "company_id", limit: 4,                  null: false
    t.string   "name",       limit: 255,                null: false
    t.string   "gl_code",    limit: 255
    t.boolean  "active",                 default: true, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "company_tags", ["company_id"], name: "index_company_tags_on_company_id", using: :btree

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

  create_table "currencies", force: :cascade do |t|
    t.string   "country",      limit: 255
    t.string   "country_code", limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

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
    t.integer  "amount_id",         limit: 4
    t.integer  "expense_status_id", limit: 4
    t.text     "note",              limit: 65535
    t.datetime "date"
    t.integer  "user_id",           limit: 4
    t.integer  "expense_type_id",   limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "manager_memo",      limit: 255
    t.integer  "category_id",       limit: 4
  end

  add_index "expenses", ["amount_id"], name: "index_expenses_on_amount_id", using: :btree
  add_index "expenses", ["category_id"], name: "index_expenses_on_category_id", using: :btree
  add_index "expenses", ["expense_status_id"], name: "index_expenses_on_expense_status_id", using: :btree
  add_index "expenses", ["expense_type_id"], name: "index_expenses_on_expense_type_id", using: :btree
  add_index "expenses", ["user_id"], name: "index_expenses_on_user_id", using: :btree

  create_table "manual_expenses", force: :cascade do |t|
    t.integer  "expense_id", limit: 4
    t.string   "merchant",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "manual_expenses", ["expense_id"], name: "index_manual_expenses_on_expense_id", using: :btree

  create_table "policies", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "company_id", limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "default",                default: false, null: false
  end

  add_index "policies", ["company_id"], name: "index_policies_on_company_id", using: :btree

  create_table "policy_configurations", force: :cascade do |t|
    t.integer  "policy_id",                limit: 4,                 null: false
    t.boolean  "require_category",                   default: false, null: false
    t.boolean  "default_reimbursable_set",           default: false, null: false
    t.boolean  "default_billable_set",               default: false, null: false
    t.integer  "report_currency_id",       limit: 4
    t.integer  "technical_contact_id",     limit: 4
    t.boolean  "mandate_expense_tagging",            default: false, null: false
    t.integer  "default_tag_id",           limit: 4
    t.boolean  "active",                             default: true,  null: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  add_index "policy_configurations", ["default_tag_id"], name: "index_policy_configurations_on_default_tag_id", using: :btree
  add_index "policy_configurations", ["policy_id"], name: "index_policy_configurations_on_policy_id", using: :btree
  add_index "policy_configurations", ["report_currency_id"], name: "index_policy_configurations_on_report_currency_id", using: :btree
  add_index "policy_configurations", ["technical_contact_id"], name: "index_policy_configurations_on_technical_contact_id", using: :btree

  create_table "policy_user_mappings", force: :cascade do |t|
    t.integer  "user_id",    limit: 4, null: false
    t.integer  "policy_id",  limit: 4, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "policy_user_mappings", ["policy_id"], name: "index_policy_user_mappings_on_policy_id", using: :btree
  add_index "policy_user_mappings", ["user_id"], name: "index_policy_user_mappings_on_user_id", using: :btree

  create_table "receipts", force: :cascade do |t|
    t.integer  "expense_id",         limit: 4
    t.integer  "user_id",            limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.integer  "parent_id",          limit: 4
    t.string   "parent_type",        limit: 255
  end

  add_index "receipts", ["expense_id"], name: "index_receipts_on_expense_id", using: :btree
  add_index "receipts", ["parent_type", "parent_id"], name: "index_receipts_on_parent_type_and_parent_id", using: :btree
  add_index "receipts", ["user_id"], name: "index_receipts_on_user_id", using: :btree

  create_table "rule_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "user_manager_mappings", force: :cascade do |t|
    t.integer  "user_id",                     limit: 4
    t.integer  "manager_id",                  limit: 4
    t.integer  "finance_manager_id",          limit: 4
    t.integer  "approves_to_user_id",         limit: 4
    t.integer  "approves_finance_to_user_id", limit: 4
    t.integer  "greater_than_amount_id",      limit: 4
    t.boolean  "default",                               default: false, null: false
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.integer  "policy_id",                   limit: 4
  end

  add_index "user_manager_mappings", ["approves_finance_to_user_id"], name: "index_user_manager_mappings_on_approves_finance_to_user_id", using: :btree
  add_index "user_manager_mappings", ["approves_to_user_id"], name: "index_user_manager_mappings_on_approves_to_user_id", using: :btree
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
    t.integer  "employee_id",         limit: 4
    t.integer  "payroll_id",          limit: 4
    t.integer  "default_currency_id", limit: 4
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.boolean  "mobile_verified",                 default: true, null: false
  end

  add_index "user_profiles", ["default_currency_id"], name: "index_user_profiles_on_default_currency_id", using: :btree
  add_index "user_profiles", ["user_id"], name: "index_user_profiles_on_user_id", using: :btree

  create_table "user_role_mappings", force: :cascade do |t|
    t.integer  "user_id",      limit: 4, null: false
    t.integer  "user_role_id", limit: 4, null: false
    t.integer  "policy_id",    limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "user_role_mappings", ["policy_id"], name: "index_user_role_mappings_on_policy_id", using: :btree
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

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",   null: false
    t.string   "encrypted_password",     limit: 255, default: "",   null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.integer  "failed_attempts",        limit: 4,   default: 0,    null: false
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "company_id",             limit: 4,                  null: false
    t.string   "name",                   limit: 255
    t.integer  "mobile_number",          limit: 4
    t.boolean  "active",                             default: true, null: false
  end

  add_index "users", ["company_id"], name: "index_users_on_company_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
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

  add_foreign_key "amounts", "currencies"
  add_foreign_key "budget_rules", "amounts"
  add_foreign_key "budget_rules", "budget_periods"
  add_foreign_key "budget_rules", "categories"
  add_foreign_key "budget_rules", "policies"
  add_foreign_key "budget_rules", "rule_types"
  add_foreign_key "categories", "companies"
  add_foreign_key "company_configurations", "companies"
  add_foreign_key "company_configurations", "contacts"
  add_foreign_key "company_tags", "companies"
  add_foreign_key "expense_rules", "categories"
  add_foreign_key "expense_rules", "expense_rule_types"
  add_foreign_key "expense_rules", "policies"
  add_foreign_key "expense_rules", "rule_types"
  add_foreign_key "expenses", "amounts"
  add_foreign_key "expenses", "categories"
  add_foreign_key "expenses", "expense_statuses"
  add_foreign_key "expenses", "expense_types"
  add_foreign_key "expenses", "users"
  add_foreign_key "manual_expenses", "expenses"
  add_foreign_key "policies", "companies"
  add_foreign_key "policy_configurations", "policies"
  add_foreign_key "policy_user_mappings", "policies"
  add_foreign_key "policy_user_mappings", "users"
  add_foreign_key "receipts", "expenses"
  add_foreign_key "receipts", "users"
  add_foreign_key "user_manager_mappings", "policies"
  add_foreign_key "user_manager_mappings", "users"
  add_foreign_key "user_profiles", "users"
  add_foreign_key "user_role_mappings", "policies"
  add_foreign_key "user_role_mappings", "user_roles"
  add_foreign_key "user_role_mappings", "users"
  add_foreign_key "user_tags", "users"
  add_foreign_key "users", "companies"
end
