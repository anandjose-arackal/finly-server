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

ActiveRecord::Schema.define(version: 20160630084358) do

  create_table "amounts", force: :cascade do |t|
    t.float    "value",       limit: 24
    t.integer  "currency_id", limit: 4,  null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "amounts", ["currency_id"], name: "index_amounts_on_currency_id", using: :btree

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

  create_table "policies", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "company_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "policies", ["company_id"], name: "index_policies_on_company_id", using: :btree

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
    t.integer  "user_id",      limit: 4
    t.integer  "user_role_id", limit: 4
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

  add_foreign_key "amounts", "currencies"
  add_foreign_key "company_configurations", "companies"
  add_foreign_key "company_configurations", "contacts"
  add_foreign_key "policies", "companies"
  add_foreign_key "user_manager_mappings", "policies"
  add_foreign_key "user_manager_mappings", "users"
  add_foreign_key "user_profiles", "users"
  add_foreign_key "user_role_mappings", "user_roles"
  add_foreign_key "user_role_mappings", "users"
  add_foreign_key "users", "companies"
end
