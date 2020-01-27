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

ActiveRecord::Schema.define(version: 2020_01_27_080031) do

  create_table "account_reconciliation_balances", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "reconciliation_balance_id"
    t.integer "account_id"
    t.integer "account_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["account_id"], name: "index_account_reconciliation_balances_on_account_id"
    t.index ["account_type"], name: "index_account_reconciliation_balances_on_account_type"
  end

  create_table "accounting_system_configurations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "company_id", null: false
    t.boolean "enabled", default: false
    t.string "accounting_system"
    t.text "options"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["accounting_system"], name: "index_accounting_system_configurations_on_accounting_system"
    t.index ["company_id"], name: "index_accounting_system_configurations_on_company_id"
  end

  create_table "active_admin_comments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_id", null: false
    t.string "resource_type", null: false
    t.integer "author_id"
    t.string "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "addresses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "line_1"
    t.text "line_2"
    t.text "line_3"
    t.string "city"
    t.integer "state_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "pin_code"
    t.boolean "default"
    t.string "parent_type"
    t.integer "parent_id"
    t.string "address_name"
    t.text "landmark"
    t.datetime "deleted_at"
    t.index ["state_id"], name: "fk_rails_2d87b6c11e"
  end

  create_table "admin_implementation_requests", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "admin_user_id", null: false
    t.string "request_key", null: false
    t.text "request_params", limit: 4294967295
    t.string "master"
    t.string "name"
    t.integer "status", null: false
    t.text "message"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.decimal "runtime", precision: 10
    t.integer "requested_items"
    t.integer "completed_items"
    t.string "request_file_file_name"
    t.string "request_file_content_type"
    t.bigint "request_file_file_size"
    t.datetime "request_file_updated_at"
    t.string "result_file_file_name"
    t.string "result_file_content_type"
    t.bigint "result_file_file_size"
    t.datetime "result_file_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "success_items", default: 0
    t.integer "failed_items", default: 0
    t.datetime "deleted_at"
    t.index ["admin_user_id"], name: "index_admin_implementation_requests_on_admin_user_id"
    t.index ["company_id"], name: "index_admin_implementation_requests_on_company_id"
    t.index ["request_key"], name: "index_admin_implementation_requests_on_request_key"
    t.index ["status"], name: "index_admin_implementation_requests_on_status"
  end

  create_table "admin_review_workflow_levels", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "admin_review_workflow_id", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "trigger_email", default: false, null: false
    t.boolean "reviewer", default: false, null: false
    t.integer "admin_user_id", null: false
    t.datetime "email_triggered_at"
    t.datetime "deleted_at"
    t.index ["admin_review_workflow_id"], name: "index_admin_review_workflow_levels_on_admin_review_workflow_id"
    t.index ["position"], name: "index_admin_review_workflow_levels_on_position"
  end

  create_table "admin_review_workflows", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["name"], name: "index_admin_review_workflows_on_name"
  end

  create_table "admin_summary_mail_configs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "period_id", null: false
    t.integer "starting_day_of_month"
    t.integer "scheduled_day_of_month"
    t.string "starting_day_of_week"
    t.string "scheduled_day_of_week"
    t.string "scheduled_time", null: false
    t.string "application", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application"], name: "index_admin_summary_mail_configs_on_application"
    t.index ["period_id"], name: "index_admin_summary_mail_configs_on_period_id"
    t.index ["scheduled_day_of_month"], name: "index_admin_summary_mail_configs_on_scheduled_day_of_month"
    t.index ["scheduled_day_of_week"], name: "index_admin_summary_mail_configs_on_scheduled_day_of_week"
    t.index ["scheduled_time"], name: "index_admin_summary_mail_configs_on_scheduled_time"
    t.index ["starting_day_of_month"], name: "index_admin_summary_mail_configs_on_starting_day_of_month"
    t.index ["starting_day_of_week"], name: "index_admin_summary_mail_configs_on_starting_day_of_week"
    t.index ["user_id"], name: "index_admin_summary_mail_configs_on_user_id"
  end

  create_table "admin_user_role_mappings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "admin_user_id"
    t.integer "admin_user_role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["admin_user_id"], name: "index_admin_user_role_mappings_on_admin_user_id"
    t.index ["admin_user_role_id"], name: "index_admin_user_role_mappings_on_admin_user_role_id"
  end

  create_table "admin_user_roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "mobile_number", null: false
    t.string "encrypted_master_password"
    t.string "authorized_ip"
    t.datetime "deleted_at"
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "advance_amount_statuses", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "agreement_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "agreements", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "agreement_type_id", null: false
    t.string "file_file_name", null: false
    t.string "file_content_type", null: false
    t.integer "file_file_size", null: false
    t.datetime "file_updated_at", null: false
    t.string "version", null: false
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.datetime "deleted_at"
    t.index ["agreement_type_id"], name: "index_agreements_on_agreement_type_id"
  end

  create_table "amounts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.decimal "value", precision: 64, scale: 12
    t.integer "currency_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "INR", precision: 20, scale: 5
    t.decimal "USD", precision: 20, scale: 5
    t.decimal "GBP", precision: 20, scale: 5
    t.decimal "CAD", precision: 20, scale: 5
    t.decimal "EUR", precision: 20, scale: 5
    t.decimal "HRK", precision: 20, scale: 5
    t.decimal "RUB", precision: 20, scale: 5
    t.decimal "BGN", precision: 20, scale: 5
    t.decimal "BRL", precision: 20, scale: 5
    t.decimal "CHF", precision: 20, scale: 5
    t.decimal "CNY", precision: 20, scale: 5
    t.decimal "CZK", precision: 20, scale: 5
    t.decimal "DKK", precision: 20, scale: 5
    t.decimal "HKD", precision: 20, scale: 5
    t.decimal "HUF", precision: 20, scale: 5
    t.decimal "IDR", precision: 20, scale: 5
    t.decimal "ILS", precision: 20, scale: 5
    t.decimal "JPY", precision: 20, scale: 5
    t.decimal "KRW", precision: 20, scale: 5
    t.decimal "MXN", precision: 20, scale: 5
    t.decimal "NOK", precision: 20, scale: 5
    t.decimal "NZD", precision: 20, scale: 5
    t.decimal "PHP", precision: 20, scale: 5
    t.decimal "PLN", precision: 20, scale: 5
    t.decimal "RON", precision: 20, scale: 5
    t.decimal "SEK", precision: 20, scale: 5
    t.decimal "SGD", precision: 20, scale: 5
    t.decimal "THB", precision: 20, scale: 5
    t.decimal "TRY", precision: 20, scale: 5
    t.decimal "ZAR", precision: 20, scale: 5
    t.decimal "AUD", precision: 20, scale: 5
    t.decimal "AED", precision: 20, scale: 5
    t.decimal "AFN", precision: 20, scale: 5
    t.decimal "ALL", precision: 20, scale: 5
    t.decimal "AMD", precision: 20, scale: 5
    t.decimal "ANG", precision: 20, scale: 5
    t.decimal "AOA", precision: 20, scale: 5
    t.decimal "ARS", precision: 20, scale: 5
    t.decimal "AWG", precision: 20, scale: 5
    t.decimal "AZN", precision: 20, scale: 5
    t.decimal "BAM", precision: 20, scale: 5
    t.decimal "BBD", precision: 20, scale: 5
    t.decimal "BDT", precision: 20, scale: 5
    t.decimal "BHD", precision: 20, scale: 5
    t.decimal "BIF", precision: 20, scale: 5
    t.decimal "BMD", precision: 20, scale: 5
    t.decimal "BND", precision: 20, scale: 5
    t.decimal "BOB", precision: 20, scale: 5
    t.decimal "BSD", precision: 20, scale: 5
    t.decimal "BTC", precision: 20, scale: 5
    t.decimal "BTN", precision: 20, scale: 5
    t.decimal "BWP", precision: 20, scale: 5
    t.decimal "BYN", precision: 20, scale: 5
    t.decimal "BYR", precision: 20, scale: 5
    t.decimal "BZD", precision: 20, scale: 5
    t.decimal "CDF", precision: 20, scale: 5
    t.decimal "CLF", precision: 20, scale: 5
    t.decimal "CLP", precision: 20, scale: 5
    t.decimal "COP", precision: 20, scale: 5
    t.decimal "CRC", precision: 20, scale: 5
    t.decimal "CUC", precision: 20, scale: 5
    t.decimal "CUP", precision: 20, scale: 5
    t.decimal "CVE", precision: 20, scale: 5
    t.decimal "DJF", precision: 20, scale: 5
    t.decimal "DOP", precision: 20, scale: 5
    t.decimal "DZD", precision: 20, scale: 5
    t.decimal "EEK", precision: 20, scale: 5
    t.decimal "EGP", precision: 20, scale: 5
    t.decimal "ERN", precision: 20, scale: 5
    t.decimal "ETB", precision: 20, scale: 5
    t.decimal "FJD", precision: 20, scale: 5
    t.decimal "FKP", precision: 20, scale: 5
    t.decimal "GEL", precision: 20, scale: 5
    t.decimal "GGP", precision: 20, scale: 5
    t.decimal "GHS", precision: 20, scale: 5
    t.decimal "GIP", precision: 20, scale: 5
    t.decimal "GMD", precision: 20, scale: 5
    t.decimal "GNF", precision: 20, scale: 5
    t.decimal "GTQ", precision: 20, scale: 5
    t.decimal "GYD", precision: 20, scale: 5
    t.decimal "HNL", precision: 20, scale: 5
    t.decimal "HTG", precision: 20, scale: 5
    t.decimal "IMP", precision: 20, scale: 5
    t.decimal "IQD", precision: 20, scale: 5
    t.decimal "IRR", precision: 20, scale: 5
    t.decimal "ISK", precision: 20, scale: 5
    t.decimal "JEP", precision: 20, scale: 5
    t.decimal "JMD", precision: 20, scale: 5
    t.decimal "JOD", precision: 20, scale: 5
    t.decimal "KES", precision: 20, scale: 5
    t.decimal "KGS", precision: 20, scale: 5
    t.decimal "KHR", precision: 20, scale: 5
    t.decimal "KMF", precision: 20, scale: 5
    t.decimal "KPW", precision: 20, scale: 5
    t.decimal "KWD", precision: 20, scale: 5
    t.decimal "KYD", precision: 20, scale: 5
    t.decimal "KZT", precision: 20, scale: 5
    t.decimal "LAK", precision: 20, scale: 5
    t.decimal "LBP", precision: 20, scale: 5
    t.decimal "LKR", precision: 20, scale: 5
    t.decimal "LRD", precision: 20, scale: 5
    t.decimal "LSL", precision: 20, scale: 5
    t.decimal "LTL", precision: 20, scale: 5
    t.decimal "LVL", precision: 20, scale: 5
    t.decimal "LYD", precision: 20, scale: 5
    t.decimal "MAD", precision: 20, scale: 5
    t.decimal "MDL", precision: 20, scale: 5
    t.decimal "MGA", precision: 20, scale: 5
    t.decimal "MKD", precision: 20, scale: 5
    t.decimal "MMK", precision: 20, scale: 5
    t.decimal "MNT", precision: 20, scale: 5
    t.decimal "MOP", precision: 20, scale: 5
    t.decimal "MRO", precision: 20, scale: 5
    t.decimal "MUR", precision: 20, scale: 5
    t.decimal "MVR", precision: 20, scale: 5
    t.decimal "MWK", precision: 20, scale: 5
    t.decimal "MZN", precision: 20, scale: 5
    t.decimal "NAD", precision: 20, scale: 5
    t.decimal "NGN", precision: 20, scale: 5
    t.decimal "NIO", precision: 20, scale: 5
    t.decimal "NPR", precision: 20, scale: 5
    t.decimal "OMR", precision: 20, scale: 5
    t.decimal "PAB", precision: 20, scale: 5
    t.decimal "PEN", precision: 20, scale: 5
    t.decimal "PGK", precision: 20, scale: 5
    t.decimal "PKR", precision: 20, scale: 5
    t.decimal "PYG", precision: 20, scale: 5
    t.decimal "QAR", precision: 20, scale: 5
    t.decimal "RSD", precision: 20, scale: 5
    t.decimal "RWF", precision: 20, scale: 5
    t.decimal "SAR", precision: 20, scale: 5
    t.decimal "SBD", precision: 20, scale: 5
    t.decimal "SCR", precision: 20, scale: 5
    t.decimal "SDG", precision: 20, scale: 5
    t.decimal "SHP", precision: 20, scale: 5
    t.decimal "SLL", precision: 20, scale: 5
    t.decimal "SOS", precision: 20, scale: 5
    t.decimal "SRD", precision: 20, scale: 5
    t.decimal "STD", precision: 20, scale: 5
    t.decimal "SVC", precision: 20, scale: 5
    t.decimal "SYP", precision: 20, scale: 5
    t.decimal "SZL", precision: 20, scale: 5
    t.decimal "TJS", precision: 20, scale: 5
    t.decimal "TMT", precision: 20, scale: 5
    t.decimal "TND", precision: 20, scale: 5
    t.decimal "TOP", precision: 20, scale: 5
    t.decimal "TTD", precision: 20, scale: 5
    t.decimal "TWD", precision: 20, scale: 5
    t.decimal "TZS", precision: 20, scale: 5
    t.decimal "UAH", precision: 20, scale: 5
    t.decimal "UGX", precision: 20, scale: 5
    t.decimal "UYU", precision: 20, scale: 5
    t.decimal "UZS", precision: 20, scale: 5
    t.decimal "VEF", precision: 20, scale: 5
    t.decimal "VND", precision: 20, scale: 5
    t.decimal "VUV", precision: 20, scale: 5
    t.decimal "WST", precision: 20, scale: 5
    t.decimal "XAF", precision: 20, scale: 5
    t.decimal "XAG", precision: 20, scale: 5
    t.decimal "XAU", precision: 20, scale: 5
    t.decimal "XCD", precision: 20, scale: 5
    t.decimal "XDR", precision: 20, scale: 5
    t.decimal "XOF", precision: 20, scale: 5
    t.decimal "XPF", precision: 20, scale: 5
    t.decimal "YER", precision: 20, scale: 5
    t.decimal "ZMK", precision: 20, scale: 5
    t.decimal "ZMW", precision: 20, scale: 5
    t.decimal "ZWL", precision: 20, scale: 5
    t.boolean "is_deleted", default: false
    t.decimal "MYR", precision: 20, scale: 5
    t.datetime "deleted_at"
    t.index ["created_at"], name: "index_amounts_on_created_at"
    t.index ["currency_id"], name: "index_amounts_on_currency_id"
    t.index ["deleted_at"], name: "index_amounts_on_deleted_at"
  end

  create_table "api_tokens", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "base_url"
    t.string "name"
    t.string "username"
    t.string "password"
    t.string "client_id"
    t.string "client_secret"
    t.string "grant_type"
    t.string "content_type"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "approval_routes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "purpose_id", null: false
    t.integer "level", null: false
    t.integer "reviewer_id", null: false
    t.integer "threshold", default: 0, null: false
    t.integer "created_by_user_id", null: false
    t.integer "user_id"
    t.integer "policy_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["created_by_user_id"], name: "index_approval_routes_on_created_by_user_id"
    t.index ["level"], name: "index_approval_routes_on_level"
    t.index ["policy_id"], name: "index_approval_routes_on_policy_id"
    t.index ["purpose_id"], name: "index_approval_routes_on_purpose_id"
    t.index ["reviewer_id"], name: "index_approval_routes_on_reviewer_id"
    t.index ["threshold"], name: "index_approval_routes_on_threshold"
    t.index ["user_id"], name: "index_approval_routes_on_user_id"
  end

  create_table "artifacts", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "resource_id"
    t.string "resource_type"
    t.string "attachment_file_name"
    t.integer "attachment_file_size"
    t.string "attachment_content_type"
    t.datetime "attachment_updated_at"
    t.text "description"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id"
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_artifacts_on_company_id"
    t.index ["creator_id"], name: "index_artifacts_on_creator_id"
    t.index ["resource_id", "resource_type"], name: "index_artifacts_on_resource_id_and_resource_type"
  end

  create_table "attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "resource_id"
    t.string "resource_type"
    t.string "file_file_name"
    t.decimal "file_file_size", precision: 64, scale: 12
    t.string "file_content_type"
    t.datetime "file_updated_at"
    t.integer "company_id"
    t.integer "creator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_attachments_on_company_id"
    t.index ["creator_id"], name: "index_attachments_on_creator_id"
    t.index ["resource_id", "resource_type"], name: "index_attachments_on_resource_id_and_resource_type"
  end

  create_table "authentications", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "email"
    t.string "nickname"
    t.string "first_name"
    t.string "last_name"
    t.string "location"
    t.string "description"
    t.string "image"
    t.string "phone"
    t.string "urls"
    t.string "token"
    t.string "secret"
    t.boolean "expires"
    t.datetime "expires_at"
    t.datetime "refresh_token_at"
    t.text "extra"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["user_id"], name: "index_authentications_on_user_id"
  end

  create_table "auto_reload_configs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "minimum_balance_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "enabled", default: false
    t.integer "reloadable_id"
    t.string "reloadable_type"
    t.integer "threshold_balance_id"
    t.integer "target_balance_id"
    t.integer "source_account_id"
    t.string "source_account_type"
    t.string "application"
    t.datetime "deleted_at"
    t.index ["reloadable_type", "reloadable_id"], name: "index_auto_reload_configs_on_reloadable_type_and_reloadable_id"
  end

  create_table "auto_submit_configs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.boolean "enabled", default: false, null: false
    t.boolean "limit_to_card_expenses", default: false, null: false
    t.integer "period_id", null: false
    t.text "default_memo"
    t.integer "default_policy_id"
    t.integer "submitable_id", null: false
    t.string "submitable_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["default_policy_id"], name: "index_auto_submit_configs_on_default_policy_id"
    t.index ["period_id"], name: "index_auto_submit_configs_on_period_id"
    t.index ["submitable_type", "submitable_id"], name: "index_auto_submit_configs_on_submitable_type_and_submitable_id"
  end

  create_table "auto_sync_config_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "auto_sync_configs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "company_id"
    t.integer "auto_sync_config_type_id"
    t.boolean "categories_sync", default: false
    t.boolean "company_tags_sync", default: false
    t.boolean "external_users_sync", default: false
    t.boolean "reports_sync", default: false
    t.integer "period_id"
    t.boolean "enabled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["auto_sync_config_type_id"], name: "index_auto_sync_configs_on_auto_sync_config_type_id"
    t.index ["company_id"], name: "index_auto_sync_configs_on_company_id"
    t.index ["period_id"], name: "index_auto_sync_configs_on_period_id"
  end

  create_table "balance_sheets", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "cash_in_hand_id"
    t.integer "approved_reports_total_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "pending_advance_id"
    t.datetime "deleted_at"
    t.index ["approved_reports_total_id"], name: "index_balance_sheets_on_approved_reports_total_id"
    t.index ["cash_in_hand_id"], name: "index_balance_sheets_on_cash_in_hand_id"
    t.index ["user_id"], name: "index_balance_sheets_on_user_id"
  end

  create_table "balance_tally_ledgers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.date "date"
    t.integer "api_balance_id"
    t.integer "finly_database_balance_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "calculated_balance_id"
    t.datetime "deleted_at"
    t.index ["api_balance_id"], name: "index_balance_tally_ledgers_on_api_balance_id"
    t.index ["finly_database_balance_id"], name: "index_balance_tally_ledgers_on_finly_database_balance_id"
  end

  create_table "bank_account_masters", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "account_number"
    t.string "ifsc"
    t.string "account_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "bank_account_providers", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "bank_accounts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "yes_bank_vendor_id"
    t.string "account_number"
    t.string "ifsc"
    t.string "name"
    t.string "address_1"
    t.string "address_2"
    t.string "address_3"
    t.string "pin_code"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "account_owner_id"
    t.string "account_owner_type"
    t.integer "company_id"
    t.boolean "reimbursable"
    t.boolean "default_account", default: false
    t.boolean "is_deleted", default: false
    t.boolean "disabled", default: false
    t.datetime "deleted_at"
    t.boolean "on_hold", default: false
    t.integer "bank_account_master_id"
    t.index ["account_number"], name: "index_bank_accounts_on_account_number"
    t.index ["account_owner_type", "account_owner_id"], name: "index_bank_accounts_on_account_owner_type_and_account_owner_id"
    t.index ["company_id"], name: "index_bank_accounts_on_company_id"
    t.index ["deleted_at"], name: "index_bank_accounts_on_deleted_at"
    t.index ["ifsc"], name: "index_bank_accounts_on_ifsc"
    t.index ["name"], name: "index_bank_accounts_on_name"
    t.index ["yes_bank_vendor_id"], name: "index_bank_accounts_on_yes_bank_vendor_id"
  end

  create_table "bank_details_masters", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "ifsc_prefix"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "bank_payment_request_comment_actions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bank_payment_request_comments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "content"
    t.integer "action_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "bank_payment_request_id"
    t.integer "user_id"
    t.integer "forwarded_to_user_id"
    t.text "note"
    t.text "previous_value"
    t.text "new_value"
    t.text "edited_field"
    t.integer "beneficiary_id"
    t.datetime "deleted_at"
    t.index ["action_id"], name: "index_bank_payment_request_comments_on_action_id"
    t.index ["user_id"], name: "index_bank_payment_request_comments_on_user_id"
  end

  create_table "bank_payment_request_statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bank_payment_request_trail_actions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bank_payment_request_trails", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "bank_payment_request_id"
    t.integer "request_status_id"
    t.integer "action_user_id"
    t.integer "action_user_role_id"
    t.integer "modified_user_id"
    t.integer "modified_user_role_id"
    t.integer "action_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "action_for_user_id"
    t.integer "action_for_user_role_id"
    t.datetime "deleted_at"
    t.index ["action_id"], name: "index_bank_payment_request_trails_on_action_id"
    t.index ["action_user_id"], name: "index_bank_payment_request_trails_on_action_user_id"
    t.index ["action_user_role_id"], name: "index_bank_payment_request_trails_on_action_user_role_id"
    t.index ["bank_payment_request_id"], name: "index_bank_payment_request_trails_on_bank_payment_request_id"
    t.index ["modified_user_id"], name: "index_bank_payment_request_trails_on_modified_user_id"
    t.index ["modified_user_role_id"], name: "index_bank_payment_request_trails_on_modified_user_role_id"
    t.index ["request_status_id"], name: "index_bank_payment_request_trails_on_request_status_id"
  end

  create_table "bank_payment_requests", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "owner_id"
    t.integer "status_id"
    t.integer "controlling_user_id"
    t.integer "payment_order_id"
    t.string "name"
    t.integer "requested_amount_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "submitted_at"
    t.integer "controlling_user_role_id"
    t.text "description"
    t.integer "controlling_for_user_id"
    t.integer "controlling_for_user_role_id"
    t.boolean "require_approval"
    t.boolean "is_deleted"
    t.integer "beneficiary_type_id"
    t.integer "policy_id"
    t.boolean "payment_file_downloaded", default: false
    t.boolean "auto_approved"
    t.boolean "api_initiated", default: false
    t.datetime "deleted_at"
    t.integer "controlling_level_id"
    t.datetime "approved_at"
    t.integer "company_id"
    t.decimal "max_payment_amount", precision: 20, scale: 5
    t.text "rejection_note"
    t.integer "bank_account_provider_id"
    t.string "otp"
    t.datetime "otp_sent_at"
    t.integer "otp_attempts"
    t.integer "otp_count"
    t.integer "expected_payments", default: 0
    t.string "ticket_type"
    t.integer "transfer_mode_id"
    t.index ["company_id"], name: "index_bank_payment_requests_on_company_id"
    t.index ["controlling_level_id"], name: "index_bank_payment_requests_on_controlling_level_id"
    t.index ["controlling_user_id"], name: "index_bank_payment_requests_on_controlling_user_id"
    t.index ["created_at"], name: "index_bank_payment_requests_on_created_at"
    t.index ["deleted_at"], name: "index_bank_payment_requests_on_deleted_at"
    t.index ["owner_id"], name: "index_bank_payment_requests_on_owner_id"
    t.index ["requested_amount_id"], name: "index_bank_payment_requests_on_requested_amount_id"
    t.index ["status_id"], name: "index_bank_payment_requests_on_status_id"
    t.index ["ticket_type"], name: "index_bank_payment_requests_on_ticket_type"
    t.index ["transfer_mode_id"], name: "index_bank_payment_requests_on_transfer_mode_id"
  end

  create_table "bank_transaction_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bank_transfer_statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bbps_bill_statuses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bbps_biller_subscription_statuses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_bbps_biller_subscription_statuses_on_name"
  end

  create_table "bbps_biller_subscriptions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "bbps_biller_id", null: false
    t.string "name", null: false
    t.string "sequence_id", null: false
    t.integer "department_id"
    t.integer "cost_center_id"
    t.integer "location_id"
    t.integer "policy_id"
    t.datetime "deleted_at"
    t.boolean "active", default: true
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status_id", null: false
    t.integer "user_id"
    t.integer "agreement_id"
    t.string "expected_bill_day"
    t.integer "controlling_level_id"
    t.string "reminder_before_days"
    t.string "biller_category_name"
    t.datetime "submitted_at"
    t.datetime "approved_at"
    t.integer "company_id"
    t.string "mobile_number"
    t.string "customer_param_key_1"
    t.string "customer_param_value_1"
    t.string "customer_param_key_2"
    t.string "customer_param_value_2"
    t.string "customer_param_key_3"
    t.string "customer_param_value_3"
    t.string "customer_param_key_4"
    t.string "customer_param_value_4"
    t.string "customer_param_key_5"
    t.string "customer_param_value_5"
    t.string "fetch_requirement"
    t.boolean "auto_generate_bill", default: true
    t.string "support_bill_validation"
    t.string "customer_name"
    t.string "customer_email"
    t.string "customer_aadhar_number"
    t.string "customer_pan"
    t.integer "tax_rate_id"
    t.integer "category_id"
    t.string "hsn_sac"
    t.string "quick_pay", default: "N"
    t.datetime "last_paid_at"
    t.index ["active"], name: "index_bbps_biller_subscriptions_on_active"
    t.index ["bbps_biller_id"], name: "index_bbps_biller_subscriptions_on_bbps_biller_id"
    t.index ["cost_center_id"], name: "index_bbps_biller_subscriptions_on_cost_center_id"
    t.index ["deleted_at"], name: "index_bbps_biller_subscriptions_on_deleted_at"
    t.index ["department_id"], name: "index_bbps_biller_subscriptions_on_department_id"
    t.index ["location_id"], name: "index_bbps_biller_subscriptions_on_location_id"
    t.index ["name"], name: "index_bbps_biller_subscriptions_on_name"
    t.index ["policy_id"], name: "index_bbps_biller_subscriptions_on_policy_id"
    t.index ["sequence_id"], name: "index_bbps_biller_subscriptions_on_sequence_id"
  end

  create_table "bbps_billers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "biller_id"
    t.string "biller_name"
    t.string "biller_alias_name"
    t.string "biller_category_name"
    t.string "biller_mode"
    t.boolean "biller_accepts_adhoc"
    t.boolean "parent_biller"
    t.string "parent_biller_id"
    t.string "biller_owner_shp"
    t.string "biller_coverage"
    t.string "fetch_requirement"
    t.string "payment_amount_exactness"
    t.string "support_bill_validation"
    t.date "biller_effctv_from"
    t.date "biller_effctv_to"
    t.date "biller_temp_deactivation_start"
    t.date "biller_temp_deactivation_end"
    t.text "biller_payment_modes", limit: 4294967295
    t.text "biller_payment_channels", limit: 4294967295
    t.text "biller_customer_params", limit: 4294967295
    t.text "biller_response_params", limit: 4294967295
    t.text "biller_additional_info", limit: 4294967295
    t.text "interchange_fee_conf", limit: 4294967295
    t.text "interchange_fee", limit: 4294967295
    t.string "status"
    t.text "biller_description"
    t.string "support_deemed"
    t.string "support_pending_status"
    t.string "biller_time_out"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["biller_id"], name: "index_bbps_billers_on_biller_id"
    t.index ["created_at"], name: "index_bbps_billers_on_created_at"
    t.index ["parent_biller_id"], name: "index_bbps_billers_on_parent_biller_id"
    t.index ["status"], name: "index_bbps_billers_on_status"
    t.index ["updated_at"], name: "index_bbps_billers_on_updated_at"
  end

  create_table "bbps_bills", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "subscription_id"
    t.integer "user_id"
    t.string "name"
    t.string "sequence_id"
    t.integer "department_id"
    t.integer "cost_center_id"
    t.integer "location_id"
    t.integer "policy_id"
    t.integer "controlling_level_id"
    t.integer "status_id"
    t.integer "amount_id"
    t.boolean "autofetched", default: false
    t.date "expected_due_date"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "submitted_at"
    t.datetime "approved_at"
    t.text "note"
    t.integer "company_id"
    t.integer "category_id"
    t.date "due_date"
    t.date "bill_date"
    t.string "bill_number"
    t.date "paid_on_date"
    t.string "transaction_id"
    t.string "bbps_id"
    t.string "bill_period"
    t.integer "late_payment_fee_id"
    t.integer "early_payment_fee_id"
    t.integer "convenience_fee_id"
    t.string "quick_pay", default: "N"
    t.integer "total_amount_id"
    t.boolean "early_payment_fee_selected", default: false
    t.boolean "late_payment_fee_selected", default: false
    t.boolean "convenience_fee_selected", default: false
    t.integer "bbps_biller_id"
    t.boolean "bill_validation_required"
    t.string "order_number"
    t.string "order_number_type"
    t.integer "tax_rate_id"
    t.string "hsn_sac"
    t.datetime "paid_at"
    t.index ["amount_id"], name: "index_bbps_bills_on_amount_id"
    t.index ["autofetched"], name: "index_bbps_bills_on_autofetched"
    t.index ["controlling_level_id"], name: "index_bbps_bills_on_controlling_level_id"
    t.index ["cost_center_id"], name: "index_bbps_bills_on_cost_center_id"
    t.index ["department_id"], name: "index_bbps_bills_on_department_id"
    t.index ["location_id"], name: "index_bbps_bills_on_location_id"
    t.index ["policy_id"], name: "index_bbps_bills_on_policy_id"
    t.index ["sequence_id"], name: "index_bbps_bills_on_sequence_id"
    t.index ["status_id"], name: "index_bbps_bills_on_status_id"
    t.index ["subscription_id"], name: "index_bbps_bills_on_subscription_id"
    t.index ["user_id"], name: "index_bbps_bills_on_user_id"
  end

  create_table "bbps_subscription_fields", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "label"
    t.string "value"
    t.integer "subscription_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "biller_id"
    t.datetime "deleted_at"
    t.index ["label"], name: "index_bbps_subscription_fields_on_label"
    t.index ["subscription_id"], name: "index_bbps_subscription_fields_on_subscription_id"
    t.index ["value"], name: "index_bbps_subscription_fields_on_value"
  end

  create_table "bbps_subscription_pocs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "subscription_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["subscription_id"], name: "index_bbps_subscription_pocs_on_subscription_id"
    t.index ["user_id"], name: "index_bbps_subscription_pocs_on_user_id"
  end

  create_table "bbps_yes_bank_transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "message_code"
    t.string "status"
    t.string "error_code"
    t.string "error_desc"
    t.string "order_number"
    t.string "agent_institution_id"
    t.string "channel_id"
    t.string "bbps_ref_id"
    t.string "agent_id"
    t.string "customer_name"
    t.string "customer_mobile"
    t.string "customer_email"
    t.string "customer_aadhar_no"
    t.string "customer_pan_id"
    t.string "biller_id"
    t.string "amount"
    t.string "bill_date"
    t.string "due_date"
    t.string "bill_number"
    t.string "bill_period"
    t.string "convenience_fee"
    t.string "convenience_fee_desc"
    t.string "late_payment_fee"
    t.string "early_payment_fee"
    t.string "additional_field"
    t.integer "bill_id"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "transfer_status_id"
    t.integer "amount_id"
    t.string "quick_pay", default: "N"
    t.datetime "deleted_at"
    t.index ["bill_id"], name: "index_bbps_yes_bank_transactions_on_bill_id"
    t.index ["company_id"], name: "index_bbps_yes_bank_transactions_on_company_id"
  end

  create_table "beneficiary_payment_statuses", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "beneficiary_payments", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.integer "vendor_id"
    t.integer "bank_account_id"
    t.integer "category_id"
    t.integer "department_id"
    t.integer "original_amount_id"
    t.integer "tax_amount_id"
    t.integer "payable_amount_id"
    t.boolean "inclusive_of_taxes"
    t.integer "gst_type_id"
    t.decimal "tax", precision: 10, scale: 3
    t.integer "tds_slab_id"
    t.integer "company_id"
    t.integer "sub_department_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status_id"
    t.integer "tds_amount_id"
    t.integer "balance_due_id"
    t.integer "net_amount_id"
    t.integer "gross_amount_id"
    t.decimal "roundoff_amount", precision: 20, scale: 10
    t.integer "cost_center_id"
    t.text "invoice_number"
    t.date "invoice_date"
    t.date "invoice_due_date"
    t.integer "advance_amount_id"
    t.json "payment_notification_users"
    t.integer "payment_agreement_id"
    t.string "note"
    t.integer "location_id"
    t.integer "vendor_location_id"
    t.integer "tax_rate_id"
    t.integer "resource_template_id"
    t.integer "creator_id"
    t.date "payment_agreement_upcoming_date"
    t.datetime "deleted_at"
    t.index ["advance_amount_id"], name: "index_beneficiary_payments_on_advance_amount_id"
    t.index ["balance_due_id"], name: "index_beneficiary_payments_on_balance_due_id"
    t.index ["bank_account_id"], name: "index_beneficiary_payments_on_bank_account_id"
    t.index ["category_id"], name: "index_beneficiary_payments_on_category_id"
    t.index ["company_id"], name: "index_beneficiary_payments_on_company_id"
    t.index ["cost_center_id"], name: "index_beneficiary_payments_on_cost_center_id"
    t.index ["creator_id"], name: "index_beneficiary_payments_on_creator_id"
    t.index ["department_id"], name: "index_beneficiary_payments_on_department_id"
    t.index ["gross_amount_id"], name: "index_beneficiary_payments_on_gross_amount_id"
    t.index ["gst_type_id"], name: "index_beneficiary_payments_on_gst_type_id"
    t.index ["invoice_date"], name: "index_beneficiary_payments_on_invoice_date"
    t.index ["invoice_due_date"], name: "index_beneficiary_payments_on_invoice_due_date"
    t.index ["invoice_number"], name: "index_beneficiary_payments_on_invoice_number", length: 20
    t.index ["net_amount_id"], name: "index_beneficiary_payments_on_net_amount_id"
    t.index ["original_amount_id"], name: "index_beneficiary_payments_on_original_amount_id"
    t.index ["payable_amount_id"], name: "index_beneficiary_payments_on_payable_amount_id"
    t.index ["resource_template_id"], name: "index_beneficiary_payments_on_resource_template_id"
    t.index ["status_id"], name: "index_beneficiary_payments_on_status_id"
    t.index ["sub_department_id"], name: "index_beneficiary_payments_on_sub_department_id"
    t.index ["tax_amount_id"], name: "index_beneficiary_payments_on_tax_amount_id"
    t.index ["tds_amount_id"], name: "index_beneficiary_payments_on_tds_amount_id"
    t.index ["tds_slab_id"], name: "index_beneficiary_payments_on_tds_slab_id"
    t.index ["vendor_id"], name: "index_beneficiary_payments_on_vendor_id"
  end

  create_table "bill_of_supplies", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "company_id"
    t.integer "user_id"
    t.integer "procurement_id"
    t.integer "location_id"
    t.integer "delivery_location_id"
    t.integer "vendor_id"
    t.integer "payment_term_id"
    t.integer "procurement_term_id"
    t.integer "document_status_id"
    t.string "doc_number"
    t.boolean "override_doc_number"
    t.string "prefix"
    t.string "sequence_start"
    t.date "date"
    t.date "bill_date"
    t.date "transaction_date"
    t.date "due_date"
    t.boolean "roundoff_total_enabled"
    t.decimal "roundoff_amount", precision: 10, scale: 5
    t.integer "transaction_amount_id"
    t.integer "total_before_tax_id"
    t.integer "tax_amount_id"
    t.integer "total_after_tax_id"
    t.integer "discount_amount_id"
    t.integer "balance_amount_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_deleted", default: false, null: false
    t.datetime "deleted_at"
    t.index ["balance_amount_id"], name: "index_bill_of_supplies_on_balance_amount_id"
    t.index ["company_id"], name: "index_bill_of_supplies_on_company_id"
    t.index ["deleted_at"], name: "index_bill_of_supplies_on_deleted_at"
    t.index ["delivery_location_id"], name: "index_bill_of_supplies_on_delivery_location_id"
    t.index ["discount_amount_id"], name: "index_bill_of_supplies_on_discount_amount_id"
    t.index ["document_status_id"], name: "index_bill_of_supplies_on_document_status_id"
    t.index ["location_id"], name: "index_bill_of_supplies_on_location_id"
    t.index ["payment_term_id"], name: "index_bill_of_supplies_on_payment_term_id"
    t.index ["procurement_id"], name: "index_bill_of_supplies_on_procurement_id"
    t.index ["procurement_term_id"], name: "index_bill_of_supplies_on_procurement_term_id"
    t.index ["tax_amount_id"], name: "index_bill_of_supplies_on_tax_amount_id"
    t.index ["total_after_tax_id"], name: "index_bill_of_supplies_on_total_after_tax_id"
    t.index ["total_before_tax_id"], name: "index_bill_of_supplies_on_total_before_tax_id"
    t.index ["transaction_amount_id"], name: "index_bill_of_supplies_on_transaction_amount_id"
    t.index ["user_id"], name: "index_bill_of_supplies_on_user_id"
    t.index ["vendor_id"], name: "index_bill_of_supplies_on_vendor_id"
  end

  create_table "billing_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "booking_attachments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "attachment_file_name"
    t.string "attachment_content_type"
    t.integer "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer "booking_id"
    t.integer "user_id"
    t.integer "company_id"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["booking_id"], name: "index_booking_attachments_on_booking_id"
    t.index ["company_id"], name: "index_booking_attachments_on_company_id"
    t.index ["user_id"], name: "index_booking_attachments_on_user_id"
  end

  create_table "booking_buses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
    t.string "parent_type"
    t.string "booking_class"
    t.integer "from_id", null: false
    t.integer "to_id", null: false
    t.integer "cost_id"
    t.text "boarding_point"
    t.text "drop_point"
    t.text "description"
    t.boolean "is_deleted", default: false
    t.date "departure_date"
    t.time "departure_time"
    t.date "arrival_date"
    t.time "arrival_time"
    t.integer "booking_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_booking_buses_on_deleted_at"
    t.index ["parent_type", "parent_id"], name: "index_booking_buses_on_parent_type_and_parent_id"
  end

  create_table "booking_car_rentals", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "pickup_address"
    t.string "car_type"
    t.string "car_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
    t.string "parent_type"
    t.integer "pickup_city_id", null: false
    t.integer "drop_city_id", null: false
    t.text "drop_address"
    t.datetime "pickup_datetime"
    t.datetime "drop_datetime"
    t.string "rental_company"
    t.text "description"
    t.integer "cost_id"
    t.date "pickup_date"
    t.time "pickup_time"
    t.date "drop_date"
    t.time "drop_time"
    t.boolean "is_deleted", default: false
    t.integer "booking_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_booking_car_rentals_on_deleted_at"
    t.index ["parent_type", "parent_id"], name: "index_booking_car_rentals_on_parent_type_and_parent_id"
  end

  create_table "booking_flight_classes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_booking_flight_classes_on_name"
  end

  create_table "booking_flights", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "pnr"
    t.string "airline"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
    t.string "parent_type"
    t.string "stops"
    t.string "ticket_number"
    t.integer "from_id", null: false
    t.integer "to_id", null: false
    t.text "description"
    t.string "terminal"
    t.integer "cost_id"
    t.integer "booking_class_id"
    t.boolean "is_deleted", default: false
    t.date "departure_date"
    t.time "departure_time"
    t.date "arrival_date"
    t.time "arrival_time"
    t.integer "booking_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_booking_flights_on_deleted_at"
    t.index ["parent_type", "parent_id"], name: "index_booking_flights_on_parent_type_and_parent_id"
  end

  create_table "booking_hotels", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "hotel_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
    t.string "parent_type"
    t.integer "location_id", null: false
    t.text "description"
    t.text "hotel_address"
    t.integer "number_of_guests"
    t.integer "cost_id"
    t.boolean "is_deleted", default: false
    t.date "checkin_date"
    t.time "checkin_time"
    t.date "checkout_date"
    t.time "checkout_time"
    t.integer "booking_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_booking_hotels_on_deleted_at"
    t.index ["parent_type", "parent_id"], name: "index_booking_hotels_on_parent_type_and_parent_id"
  end

  create_table "booking_others", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "parent_id"
    t.string "parent_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "booking_details"
    t.text "description"
    t.integer "cost_id"
    t.boolean "is_deleted", default: false
    t.integer "booking_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_booking_others_on_deleted_at"
    t.index ["parent_type", "parent_id"], name: "index_booking_others_on_parent_type_and_parent_id"
  end

  create_table "booking_requests", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "booking_status_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "travel_request_destination_id"
    t.integer "booking_type_id"
    t.text "note"
    t.boolean "is_deleted", default: false
    t.integer "travel_request_id", null: false
    t.datetime "deleted_at"
    t.index ["booking_status_id"], name: "index_booking_requests_on_booking_status_id"
    t.index ["booking_type_id"], name: "index_booking_requests_on_booking_type_id"
    t.index ["deleted_at"], name: "index_booking_requests_on_deleted_at"
  end

  create_table "booking_restaurants", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "restaurant_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
    t.string "parent_type"
    t.integer "location_id", null: false
    t.text "restaurant_address"
    t.integer "number_of_guests"
    t.text "description"
    t.boolean "is_deleted", default: false
    t.date "reservation_date"
    t.time "reservation_time"
    t.integer "booking_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_booking_restaurants_on_deleted_at"
    t.index ["parent_type", "parent_id"], name: "index_booking_restaurants_on_parent_type_and_parent_id"
  end

  create_table "booking_statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "booking_trains", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "train_number"
    t.string "pnr"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
    t.string "parent_type"
    t.string "booking_class"
    t.integer "from_id", null: false
    t.string "boarding_station"
    t.integer "to_id", null: false
    t.string "destination_station"
    t.string "description"
    t.string "seat_number"
    t.integer "cost_id"
    t.boolean "is_deleted", default: false
    t.date "departure_date"
    t.time "departure_time"
    t.date "arrival_date"
    t.time "arrival_time"
    t.integer "booking_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_booking_trains_on_deleted_at"
    t.index ["parent_type", "parent_id"], name: "index_booking_trains_on_parent_type_and_parent_id"
  end

  create_table "booking_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bookings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "booking_request_id"
    t.integer "booking_status_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "booking_type_id"
    t.text "note"
    t.integer "created_by_user_id"
    t.integer "travel_request_id", null: false
    t.integer "destination_id", null: false
    t.integer "parent_booking_id"
    t.text "reject_reason"
    t.datetime "deleted_at"
    t.index ["booking_request_id"], name: "index_bookings_on_booking_request_id"
    t.index ["booking_status_id"], name: "index_bookings_on_booking_status_id"
    t.index ["booking_type_id"], name: "index_bookings_on_booking_type_id"
  end

  create_table "branch_locations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "gstin"
    t.string "pan"
    t.integer "company_id"
    t.text "address_1"
    t.text "address_2"
    t.string "city"
    t.integer "state_id"
    t.string "country"
    t.string "pin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contact_name"
    t.string "contact_mobile_number"
    t.boolean "is_deleted", default: false, null: false
    t.datetime "deleted_at"
    t.string "location_code"
    t.string "ancestry"
    t.string "nature_of_office"
    t.boolean "billable_location", default: true
    t.boolean "shippable_location", default: true
    t.string "gl_code"
    t.index ["ancestry"], name: "index_branch_locations_on_ancestry"
    t.index ["company_id"], name: "index_branch_locations_on_company_id"
    t.index ["deleted_at"], name: "index_branch_locations_on_deleted_at"
    t.index ["state_id"], name: "index_branch_locations_on_state_id"
  end

  create_table "budget_criteria_mappings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "budget_id"
    t.integer "budgetable_id"
    t.string "budgetable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["budget_id"], name: "index_budget_criteria_mappings_on_budget_id"
  end

  create_table "budget_modification_actions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "budget_modification_trails", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "budget_id"
    t.integer "action_user_id"
    t.integer "action_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "previous_value"
    t.string "current_value"
    t.string "changed_column_name"
    t.datetime "deleted_at"
    t.index ["action_id"], name: "index_budget_modification_trails_on_action_id"
    t.index ["action_user_id"], name: "index_budget_modification_trails_on_action_user_id"
    t.index ["budget_id"], name: "index_budget_modification_trails_on_budget_id"
  end

  create_table "budget_rule_branch_location_mappings", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "budget_rule_id", null: false
    t.integer "branch_location_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["branch_location_id"], name: "index_budget_rule_branch_location_mappings_on_branch_location_id"
    t.index ["budget_rule_id"], name: "index_budget_rule_branch_location_mappings_on_budget_rule_id"
  end

  create_table "budget_rule_category_mappings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "budget_rule_id", null: false
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["budget_rule_id"], name: "index_budget_rule_category_mappings_on_budget_rule_id"
    t.index ["category_id"], name: "index_budget_rule_category_mappings_on_category_id"
  end

  create_table "budget_rule_department_mappings", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "budget_rule_id", null: false
    t.integer "department_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["budget_rule_id"], name: "index_budget_rule_department_mappings_on_budget_rule_id"
    t.index ["department_id"], name: "index_budget_rule_department_mappings_on_department_id"
  end

  create_table "budget_rule_expense_type_mappings", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "budget_rule_id", null: false
    t.integer "expense_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["budget_rule_id"], name: "index_budget_rule_expense_type_mappings_on_budget_rule_id"
    t.index ["expense_type_id"], name: "index_budget_rule_expense_type_mappings_on_expense_type_id"
  end

  create_table "budget_rule_field_mappings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "budget_rule_id", null: false
    t.integer "field_configuration_id", null: false
    t.integer "field_drop_down_item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["budget_rule_id"], name: "index_budget_rule_field_mappings_on_budget_rule_id"
    t.index ["field_configuration_id"], name: "index_budget_rule_field_mappings_on_field_configuration_id"
    t.index ["field_drop_down_item_id"], name: "index_budget_rule_field_mappings_on_field_drop_down_item_id"
  end

  create_table "budget_rules", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "category_id"
    t.integer "amount_id"
    t.integer "period_id"
    t.integer "policy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rule_type_id"
    t.boolean "include_reimbursable", default: true
    t.boolean "is_deleted", default: false
    t.integer "expense_type_id"
    t.integer "with_receipt_amount_id"
    t.integer "without_receipt_amount_id"
    t.datetime "deleted_at"
    t.index ["amount_id"], name: "index_budget_rules_on_amount_id"
    t.index ["category_id"], name: "index_budget_rules_on_category_id"
    t.index ["deleted_at"], name: "index_budget_rules_on_deleted_at"
    t.index ["period_id"], name: "index_budget_rules_on_period_id"
    t.index ["policy_id"], name: "index_budget_rules_on_policy_id"
    t.index ["rule_type_id"], name: "index_budget_rules_on_rule_type_id"
  end

  create_table "budget_trails", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "entity_id"
    t.string "entity_type"
    t.integer "category_id"
    t.integer "cost_center_id"
    t.integer "location_id"
    t.integer "vendor_id"
    t.integer "amount_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "department_id"
    t.date "date"
    t.integer "sub_department_id"
    t.integer "procurement_id"
    t.datetime "deleted_at"
    t.index ["entity_type", "entity_id"], name: "index_budget_trails_on_entity_type_and_entity_id"
  end

  create_table "budgets", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.integer "period_id"
    t.date "start_date"
    t.date "end_date"
    t.integer "budget_amount_id"
    t.integer "spent_amount_id"
    t.integer "budgetable_id"
    t.string "budgetable_type"
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "company_id"
    t.boolean "purchase_order"
    t.boolean "payment"
    t.boolean "expense"
    t.string "ancestry"
    t.datetime "deleted_at"
    t.index ["budget_amount_id"], name: "index_budgets_on_budget_amount_id"
    t.index ["budgetable_type", "budgetable_id"], name: "index_budgets_on_budgetable_type_and_budgetable_id"
    t.index ["company_id"], name: "index_budgets_on_company_id"
    t.index ["deleted_at"], name: "index_budgets_on_deleted_at"
    t.index ["period_id"], name: "index_budgets_on_period_id"
    t.index ["spent_amount_id"], name: "index_budgets_on_spent_amount_id"
    t.index ["user_id"], name: "index_budgets_on_user_id"
  end

  create_table "callback_tracks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "company_id"
    t.text "request"
    t.text "response", limit: 16777215
    t.integer "entity_id"
    t.string "entity_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "success"
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_callback_tracks_on_company_id"
  end

  create_table "card_assign_request_statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "card_assign_request_track_actions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "card_assign_request_tracks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "card_assign_request_id", null: false
    t.integer "action_resource_id"
    t.string "action_resource_type"
    t.integer "action_id", null: false
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["action_id"], name: "index_card_assign_request_tracks_on_action_id"
    t.index ["action_resource_id"], name: "index_card_assign_request_tracks_on_action_resource_id"
    t.index ["action_resource_type"], name: "index_card_assign_request_tracks_on_action_resource_type"
    t.index ["card_assign_request_id"], name: "index_card_assign_request_tracks_on_card_assign_request_id"
  end

  create_table "card_assign_requests", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "card_id"
    t.integer "card_owner_id", null: false
    t.integer "initiating_resource_id", null: false
    t.string "initiating_resource_type", null: false
    t.integer "status_id", null: false
    t.integer "assigned_by_resource_id"
    t.string "assigned_by_resource_type"
    t.datetime "assigned_on"
    t.integer "card_program_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "admin_review_workflow_id"
    t.integer "review_position", default: 0
    t.text "admin_note"
    t.integer "company_id", null: false
    t.datetime "deleted_at"
    t.index ["admin_review_workflow_id"], name: "index_card_assign_requests_on_admin_review_workflow_id"
    t.index ["assigned_by_resource_id"], name: "index_card_assign_requests_on_assigned_by_resource_id"
    t.index ["assigned_by_resource_type"], name: "index_card_assign_requests_on_assigned_by_resource_type"
    t.index ["card_id"], name: "index_card_assign_requests_on_card_id"
    t.index ["card_owner_id"], name: "index_card_assign_requests_on_card_owner_id"
    t.index ["card_program_id"], name: "index_card_assign_requests_on_card_program_id"
    t.index ["company_id"], name: "index_card_assign_requests_on_company_id"
    t.index ["initiating_resource_id"], name: "index_card_assign_requests_on_initiating_resource_id"
    t.index ["initiating_resource_type"], name: "index_card_assign_requests_on_initiating_resource_type"
    t.index ["status_id"], name: "index_card_assign_requests_on_status_id"
  end

  create_table "card_balance_histories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "card_id"
    t.integer "amount_id"
    t.datetime "timestamp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["amount_id"], name: "index_card_balance_histories_on_amount_id"
    t.index ["card_id"], name: "index_card_balance_histories_on_card_id"
  end

  create_table "card_configurations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "prepaid_card_id"
    t.integer "configured_by_user_id"
    t.integer "card_status_id"
    t.datetime "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["card_status_id"], name: "index_card_configurations_on_card_status_id"
    t.index ["configured_by_user_id"], name: "index_card_configurations_on_configured_by_user_id"
    t.index ["prepaid_card_id"], name: "index_card_configurations_on_prepaid_card_id"
  end

  create_table "card_expense_configs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.boolean "enabled", default: true
    t.integer "policy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["policy_id"], name: "index_card_expense_configs_on_policy_id"
  end

  create_table "card_expenses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "editable_merchant"
    t.integer "card_transaction_id"
    t.integer "expense_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "surcharge_id"
    t.boolean "is_deleted", default: false
    t.boolean "cancelled", default: false
    t.boolean "atm_surcharge", default: false
    t.datetime "deleted_at"
    t.index ["card_transaction_id"], name: "index_card_expenses_on_card_transaction_id"
    t.index ["deleted_at"], name: "index_card_expenses_on_deleted_at"
    t.index ["expense_id"], name: "index_card_expenses_on_expense_id"
  end

  create_table "card_fund_transactions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "transaction_id", null: false
    t.text "response", null: false
    t.string "action", null: false
    t.integer "requesting_user", null: false
    t.integer "for_user", null: false
    t.text "post_params", null: false
    t.text "post_url", null: false
    t.string "amount_value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["for_user"], name: "index_card_fund_transactions_on_for_user"
    t.index ["requesting_user"], name: "index_card_fund_transactions_on_requesting_user"
  end

  create_table "card_limits", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "card_restriction_id"
    t.integer "transactions"
    t.integer "period_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "budget", precision: 10
    t.integer "limit_type_id"
    t.boolean "allowed"
    t.datetime "deleted_at"
    t.index ["card_restriction_id"], name: "index_card_limits_on_card_restriction_id"
    t.index ["period_id"], name: "index_card_limits_on_period_id"
  end

  create_table "card_programs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.boolean "create_expense"
    t.boolean "receive_reimbursement"
    t.boolean "personal_wallet_fund_transfer"
    t.boolean "spend_restrictions"
    t.boolean "end_date_restrictions"
    t.boolean "manager_credit"
    t.boolean "manager_debit"
    t.boolean "manager_blockable"
    t.boolean "manager_view_balance"
    t.boolean "manager_view_eligibility"
    t.boolean "manager_view_transactions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "non_personal_fund_transfer"
    t.datetime "deleted_at"
  end

  create_table "card_request_statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "card_restrictions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "card_id"
    t.boolean "channel_atm"
    t.boolean "channel_pos"
    t.boolean "channel_online"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "channel_ecom_pos"
    t.integer "mcc_group_id"
    t.string "mcc_restriction_type"
    t.datetime "deleted_at"
    t.index ["card_id"], name: "index_card_restrictions_on_card_id"
  end

  create_table "card_statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "card_transactions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "card_id"
    t.string "merchant_name"
    t.string "transaction_type"
    t.text "post_data"
    t.integer "transaction_amount_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reference_id"
    t.string "auth_transaction_id"
    t.string "transaction_mode"
    t.string "itzcash_merchant_key"
    t.string "merchant_city"
    t.string "response_code"
    t.string "serial_id"
    t.string "product_code"
    t.datetime "transaction_timestamp"
    t.boolean "expensed", default: false
    t.text "error_message"
    t.integer "billing_amount_id"
    t.boolean "is_deleted", default: false
    t.string "mcc_code"
    t.string "transaction_status"
    t.string "api_reference_id"
    t.boolean "cancelled", default: false
    t.integer "cancelled_against_expense_id"
    t.string "type_of_details"
    t.boolean "success"
    t.string "acquirer_id"
    t.string "mid"
    t.string "tid"
    t.text "transaction_message"
    t.datetime "deleted_at"
    t.index ["card_id"], name: "index_card_transactions_on_card_id"
    t.index ["deleted_at"], name: "index_card_transactions_on_deleted_at"
    t.index ["transaction_amount_id"], name: "index_card_transactions_on_transaction_amount_id"
    t.index ["user_id"], name: "index_card_transactions_on_user_id"
  end

  create_table "card_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "cards", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.string "ending_number", null: false
    t.string "proxy", null: false
    t.integer "card_type_id"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id", null: false
    t.integer "disabled_by_role_id"
    t.integer "disabled_by_user_id"
    t.boolean "active"
    t.text "disable_note"
    t.integer "card_balance_id"
    t.integer "card_program_id"
    t.integer "card_eligibility_id"
    t.boolean "admin_unblockable", default: true
    t.integer "itz_cash_card_program_id"
    t.integer "card_status_id", null: false
    t.boolean "is_deleted", default: false
    t.boolean "hotlisted", default: false
    t.string "card_processor_status"
    t.integer "replaced_card_id"
    t.datetime "deleted_at"
    t.index ["card_type_id"], name: "index_cards_on_card_type_id"
    t.index ["company_id"], name: "index_cards_on_company_id"
    t.index ["deleted_at"], name: "index_cards_on_deleted_at"
    t.index ["user_id"], name: "index_cards_on_user_id"
  end

  create_table "cash_expense_configs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.boolean "enabled", default: true
    t.integer "policy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["policy_id"], name: "index_cash_expense_configs_on_policy_id"
  end

  create_table "cash_on_hands", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "balance_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["balance_id"], name: "index_cash_on_hands_on_balance_id"
    t.index ["user_id"], name: "index_cash_on_hands_on_user_id"
  end

  create_table "categories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "company_id", null: false
    t.string "name", null: false
    t.string "gl_code"
    t.string "payroll_code"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "purpose_id"
    t.boolean "expense_management"
    t.boolean "vendor_payments"
    t.boolean "outward_invoices"
    t.boolean "inward_invoice_line_items"
    t.string "ancestry"
    t.boolean "outward_invoice_line_items"
    t.string "category_code"
    t.boolean "gst_applicable", default: false
    t.boolean "tds_applicable"
    t.datetime "deleted_at"
    t.index ["active"], name: "index_categories_on_active"
    t.index ["ancestry"], name: "index_categories_on_ancestry"
    t.index ["company_id"], name: "index_categories_on_company_id"
    t.index ["name"], name: "index_categories_on_name"
  end

  create_table "channel_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "abbreviation"
    t.datetime "deleted_at"
  end

  create_table "city_id_city_code_mappings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "city_id"
    t.string "city_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "collect_company_details", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "gst"
    t.string "pan"
    t.integer "company_id"
    t.string "company_logo_file_name"
    t.string "company_logo_content_type"
    t.integer "company_logo_file_size"
    t.datetime "company_logo_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "address"
    t.text "pin"
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_collect_company_details_on_company_id"
  end

  create_table "collect_transaction_purposes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "collect_transaction_virtual_account_mappings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "virtual_account_id"
    t.integer "transaction_purpose_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "companies", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true, null: false
    t.integer "base_currency_id", default: 1
    t.integer "status_id", default: 1, null: false
    t.boolean "test_account", default: false
    t.string "subdomain"
    t.integer "group_id"
    t.datetime "deleted_at"
  end

  create_table "company_account_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "company_accounts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "wallet_balance_id"
    t.integer "company"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_account_type_id"
    t.datetime "deleted_at"
    t.index ["company"], name: "index_company_accounts_on_company"
    t.index ["company_account_type_id"], name: "index_company_accounts_on_company_account_type_id"
    t.index ["company_id"], name: "index_company_accounts_on_company_id"
    t.index ["wallet_balance_id"], name: "index_company_accounts_on_wallet_balance_id"
  end

  create_table "company_agreement_tracks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "agreement_id", null: false
    t.string "ip_address"
    t.string "referrer"
    t.string "application"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.datetime "deleted_at"
    t.index ["agreement_id"], name: "index_company_agreement_tracks_on_agreement_id"
    t.index ["user_id"], name: "index_company_agreement_tracks_on_user_id"
  end

  create_table "company_balance_histories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "company_id"
    t.integer "neft_transfer_id"
    t.integer "company_balance_id"
    t.integer "company_withdrawal_to_card_id"
    t.integer "company_load_from_card_id"
    t.integer "card_load_from_wallet_id"
    t.integer "card_withdrawal_to_wallet_id"
    t.integer "card_balance_id"
    t.integer "card_expenses_id"
    t.integer "wallet_load_from_wallet_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "card_atm_withdrawal_id"
    t.integer "company_withdrawal_to_wallet_id"
    t.integer "company_load_from_wallet_id"
    t.integer "card_withdrawal_to_card_id"
    t.integer "card_withdrawal_to_virtual_account_id"
    t.integer "card_load_from_card_id"
    t.integer "card_load_from_virtual_account_id"
    t.integer "wallet_withdrawal_to_wallet_id"
    t.integer "wallet_withdrawal_to_card_id"
    t.integer "wallet_withdrawal_to_virtual_account_id"
    t.integer "wallet_load_from_card_id"
    t.integer "wallet_load_from_virtual_account_id"
    t.date "date"
    t.integer "wallet_balance_id"
    t.integer "cash_on_hand_load_id"
    t.integer "cash_on_hand_withdrawal_id"
    t.integer "cash_on_hand_balance_id"
    t.datetime "deleted_at"
    t.index ["card_balance_id"], name: "index_company_balance_histories_on_card_balance_id"
    t.index ["card_expenses_id"], name: "index_company_balance_histories_on_card_expenses_id"
    t.index ["card_load_from_wallet_id"], name: "index_company_balance_histories_on_card_load_from_wallet_id"
    t.index ["card_withdrawal_to_wallet_id"], name: "index_company_balance_histories_on_card_withdrawal_to_wallet_id"
    t.index ["company_balance_id"], name: "index_company_balance_histories_on_company_balance_id"
    t.index ["company_id"], name: "index_company_balance_histories_on_company_id"
    t.index ["company_load_from_card_id"], name: "index_company_balance_histories_on_company_load_from_card_id"
    t.index ["company_withdrawal_to_card_id"], name: "index_company_balance_histories_on_company_withdrawal_to_card_id"
    t.index ["neft_transfer_id"], name: "index_company_balance_histories_on_neft_transfer_id"
    t.index ["wallet_load_from_virtual_account_id"], name: "index_wal_load_on_company_history"
    t.index ["wallet_load_from_wallet_id"], name: "index_company_balance_histories_on_wallet_load_from_wallet_id"
    t.index ["wallet_withdrawal_to_card_id"], name: "index_wal_2_card_on_company_history"
    t.index ["wallet_withdrawal_to_virtual_account_id"], name: "index_wal_2_va_on_company_history"
    t.index ["wallet_withdrawal_to_wallet_id"], name: "index_wal_2_wal_on_company_history"
  end

  create_table "company_branches", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "collect_company_detail_id"
    t.string "name"
    t.string "pan"
    t.string "gst"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.string "address_1"
    t.string "address_2"
    t.string "city"
    t.integer "state_id"
    t.string "country"
    t.string "pin"
    t.datetime "deleted_at"
    t.index ["collect_company_detail_id"], name: "index_company_branches_on_collect_company_detail_id"
    t.index ["company_id"], name: "index_company_branches_on_company_id"
  end

  create_table "company_configurations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "contact_id"
    t.boolean "verified", default: false
    t.string "logo_file_name"
    t.string "logo_content_type"
    t.integer "logo_file_size"
    t.datetime "logo_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "other_expense_types", default: false
    t.text "encrypted_easy_login_params"
    t.string "registered_mobile_number"
    t.string "bank_type"
    t.integer "default_card_expense_category_id"
    t.boolean "sso_enabled", default: false
    t.text "address"
    t.boolean "cash_money_requests_enabled", default: true
    t.boolean "auto_retry_payment", default: false
    t.string "legal_entity_name"
    t.boolean "show_custom_fields_in_pdf", default: true
    t.boolean "show_po_approved_trail", default: false
    t.boolean "email_purchase_order_initiator"
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_company_configurations_on_company_id"
    t.index ["contact_id"], name: "index_company_configurations_on_contact_id"
    t.index ["default_card_expense_category_id"], name: "index_company_configurations_on_default_card_expense_category_id"
  end

  create_table "company_departments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name", null: false
    t.integer "company_id", null: false
    t.boolean "active", default: true
    t.boolean "is_deleted", default: false
    t.integer "created_by_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["active"], name: "index_company_departments_on_active"
    t.index ["company_id"], name: "index_company_departments_on_company_id"
    t.index ["created_by_user_id"], name: "index_company_departments_on_created_by_user_id"
    t.index ["deleted_at"], name: "index_company_departments_on_deleted_at"
    t.index ["is_deleted"], name: "index_company_departments_on_is_deleted"
    t.index ["name"], name: "index_company_departments_on_name"
  end

  create_table "company_funds_auto_transfer_configs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "company_id"
    t.integer "threshold_amount_id"
    t.string "frequency_name"
    t.string "frequency_day"
    t.string "amount_transfer_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "enabled", default: false
    t.string "transfer_mode"
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_company_funds_auto_transfer_configs_on_company_id"
    t.index ["threshold_amount_id"], name: "index_company_funds_auto_transfer_configs_on_threshold_amount_id"
  end

  create_table "company_funds_load_request_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
  end

  create_table "company_funds_load_requests", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "company_id"
    t.integer "requested_by_user_id", null: false
    t.string "reference_id", null: false
    t.date "date", null: false
    t.integer "amount_id"
    t.text "remark"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "bank_type_id"
    t.boolean "is_active", default: true
    t.datetime "deleted_at"
    t.index ["amount_id"], name: "index_company_funds_load_requests_on_amount_id"
    t.index ["bank_type_id"], name: "index_company_funds_load_requests_on_bank_type_id"
    t.index ["company_id"], name: "index_company_funds_load_requests_on_company_id"
    t.index ["requested_by_user_id"], name: "index_company_funds_load_requests_on_requested_by_user_id"
  end

  create_table "company_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "default_company_id"
    t.datetime "deleted_at"
  end

  create_table "company_kyc_document_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "identifier"
    t.datetime "deleted_at"
  end

  create_table "company_kyc_trail_actions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "company_kyc_trails", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "company_kyc_id"
    t.integer "action_resource_id"
    t.string "action_resource_type"
    t.integer "action_id"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["action_id"], name: "index_company_kyc_trails_on_action_id"
    t.index ["action_resource_id", "action_resource_type"], name: "index_company_kyc_trails_on_action_resource"
    t.index ["company_kyc_id"], name: "index_company_kyc_trails_on_company_kyc_id"
  end

  create_table "company_kycs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "pan_card_file_name"
    t.string "pan_card_content_type"
    t.integer "pan_card_file_size"
    t.datetime "pan_card_updated_at"
    t.string "coi_file_name"
    t.string "coi_content_type"
    t.integer "coi_file_size"
    t.datetime "coi_updated_at"
    t.string "board_resolution_file_name"
    t.string "board_resolution_content_type"
    t.integer "board_resolution_file_size"
    t.datetime "board_resolution_updated_at"
    t.integer "kyc_status_id"
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date_of_establishment"
    t.text "street_2"
    t.text "street_3"
    t.string "registered_mobile_number"
    t.string "pan_card_no"
    t.string "pin_code"
    t.string "city_code"
    t.string "aadhar_card_file_name"
    t.string "aadhar_card_content_type"
    t.integer "aadhar_card_file_size"
    t.datetime "aadhar_card_updated_at"
    t.string "vat_registration_certificate_file_name"
    t.string "vat_registration_certificate_content_type"
    t.integer "vat_registration_certificate_file_size"
    t.datetime "vat_registration_certificate_updated_at"
    t.string "registration_of_trust_file_name"
    t.string "registration_of_trust_content_type"
    t.integer "registration_of_trust_file_size"
    t.datetime "registration_of_trust_updated_at"
    t.string "driving_licence_file_name"
    t.string "driving_licence_content_type"
    t.integer "driving_licence_file_size"
    t.datetime "driving_licence_updated_at"
    t.string "passport_file_name"
    t.string "passport_content_type"
    t.integer "passport_file_size"
    t.datetime "passport_updated_at"
    t.integer "company_type_id"
    t.string "certificate_of_registration_file_name"
    t.string "certificate_of_registration_content_type"
    t.integer "certificate_of_registration_file_size"
    t.datetime "certificate_of_registration_updated_at"
    t.integer "customer_type_id"
    t.boolean "user_confirmed", default: false
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_company_kycs_on_company_id"
    t.index ["company_type_id"], name: "index_company_kycs_on_company_type_id"
    t.index ["kyc_status_id"], name: "index_company_kycs_on_kyc_status_id"
  end

  create_table "company_location_departments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "branch_location_id", null: false
    t.integer "company_department_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["branch_location_id"], name: "index_company_location_departments_on_branch_location_id"
    t.index ["company_department_id"], name: "index_company_location_departments_on_company_department_id"
  end

  create_table "company_pocket_templates", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.integer "company_id"
    t.integer "user_pocket_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_company_pocket_templates_on_company_id"
    t.index ["user_pocket_type_id"], name: "index_company_pocket_templates_on_user_pocket_type_id"
  end

  create_table "company_statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_company_statuses_on_name"
  end

  create_table "company_tags", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "company_id", null: false
    t.string "name", null: false
    t.string "gl_code"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_company_tags_on_company_id"
  end

  create_table "company_transactions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "company_id", null: false
    t.string "request_id", null: false
    t.string "merchant_name", null: false
    t.datetime "transaction_date", null: false
    t.integer "transaction_amount_id", null: false
    t.string "transaction_type", null: false
    t.string "transaction_id", null: false
    t.integer "balance_amount_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "transaction_mode"
    t.string "merchant_type_key"
    t.datetime "deleted_at"
    t.index ["balance_amount_id"], name: "index_company_transactions_on_balance_amount_id"
    t.index ["company_id"], name: "index_company_transactions_on_company_id"
    t.index ["transaction_amount_id"], name: "index_company_transactions_on_transaction_amount_id"
  end

  create_table "company_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contacts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.string "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "contactable_id"
    t.string "contactable_type"
    t.string "designation"
    t.datetime "deleted_at"
    t.index ["contactable_id", "contactable_type"], name: "index_contacts_on_contactable_id_and_contactable_type"
  end

  create_table "cost_centers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "application"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_deleted"
    t.datetime "deleted_at"
    t.string "cost_center_code"
    t.string "ancestry"
    t.string "gl_code"
    t.index ["ancestry"], name: "index_cost_centers_on_ancestry"
    t.index ["company_id"], name: "index_cost_centers_on_company_id"
    t.index ["deleted_at"], name: "index_cost_centers_on_deleted_at"
  end

  create_table "credit_note_adjustments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "invoice_id"
    t.integer "credit_note_id"
    t.integer "amount_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["amount_id"], name: "index_credit_note_adjustments_on_amount_id"
    t.index ["credit_note_id"], name: "index_credit_note_adjustments_on_credit_note_id"
    t.index ["invoice_id"], name: "index_credit_note_adjustments_on_invoice_id"
  end

  create_table "credit_note_item_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
  end

  create_table "credit_note_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "credit_note_id"
    t.integer "item_id"
    t.integer "invoice_item_id"
    t.integer "category_id"
    t.integer "credit_note_item_type_id"
    t.text "comment"
    t.string "gl_code"
    t.string "hsn_sac"
    t.decimal "original_quantity", precision: 20, scale: 5
    t.decimal "revised_quantity", precision: 20, scale: 5
    t.decimal "quantity", precision: 20, scale: 5
    t.decimal "original_rate", precision: 20, scale: 5
    t.decimal "revised_rate", precision: 20, scale: 5
    t.decimal "rate", precision: 20, scale: 5
    t.integer "original_taxable_amount_id"
    t.integer "revised_taxable_amount_id"
    t.integer "taxable_amount_id"
    t.integer "original_tax_rate_id"
    t.integer "revised_tax_rate_id"
    t.integer "tax_rate_id"
    t.integer "total_amount_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "tax_amount_id"
    t.index ["category_id"], name: "index_credit_note_items_on_category_id"
    t.index ["credit_note_id"], name: "index_credit_note_items_on_credit_note_id"
    t.index ["credit_note_item_type_id"], name: "index_credit_note_items_on_credit_note_item_type_id"
    t.index ["invoice_item_id"], name: "index_credit_note_items_on_invoice_item_id"
    t.index ["item_id"], name: "index_credit_note_items_on_item_id"
    t.index ["original_tax_rate_id"], name: "index_credit_note_items_on_original_tax_rate_id"
    t.index ["original_taxable_amount_id"], name: "index_credit_note_items_on_original_taxable_amount_id"
    t.index ["revised_tax_rate_id"], name: "index_credit_note_items_on_revised_tax_rate_id"
    t.index ["revised_taxable_amount_id"], name: "index_credit_note_items_on_revised_taxable_amount_id"
    t.index ["tax_rate_id"], name: "index_credit_note_items_on_tax_rate_id"
    t.index ["taxable_amount_id"], name: "index_credit_note_items_on_taxable_amount_id"
    t.index ["total_amount_id"], name: "index_credit_note_items_on_total_amount_id"
  end

  create_table "credit_note_statuses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "credit_notes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "company_id"
    t.integer "user_id"
    t.integer "invoice_id"
    t.integer "procurement_id"
    t.integer "status_id"
    t.integer "controlling_level_id"
    t.integer "policy_id"
    t.integer "vendor_id"
    t.integer "shipping_location_id"
    t.integer "billing_location_id"
    t.string "sequence_id"
    t.date "credit_note_date"
    t.text "narration"
    t.text "billing_address"
    t.text "shipping_address"
    t.integer "gross_receivable_amount_id"
    t.integer "tax_amount_id"
    t.integer "discount_amount_id"
    t.integer "net_receivable_amount_id"
    t.integer "tds_rate_id"
    t.integer "tds_amount_id"
    t.integer "freight_amount_id"
    t.integer "previously_adjusted_amount_id"
    t.integer "net_adjustable_amount_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "roundoff_amount_id"
    t.integer "department_id"
    t.integer "cost_center_id"
    t.datetime "submitted_at"
    t.datetime "approved_at"
    t.string "credit_note_number"
    t.datetime "last_adjusted_at"
    t.index ["billing_location_id"], name: "index_credit_notes_on_billing_location_id"
    t.index ["company_id"], name: "index_credit_notes_on_company_id"
    t.index ["controlling_level_id"], name: "index_credit_notes_on_controlling_level_id"
    t.index ["credit_note_date"], name: "index_credit_notes_on_credit_note_date"
    t.index ["discount_amount_id"], name: "index_credit_notes_on_discount_amount_id"
    t.index ["freight_amount_id"], name: "index_credit_notes_on_freight_amount_id"
    t.index ["gross_receivable_amount_id"], name: "index_credit_notes_on_gross_receivable_amount_id"
    t.index ["invoice_id"], name: "index_credit_notes_on_invoice_id"
    t.index ["net_adjustable_amount_id"], name: "index_credit_notes_on_net_adjustable_amount_id"
    t.index ["net_receivable_amount_id"], name: "index_credit_notes_on_net_receivable_amount_id"
    t.index ["policy_id"], name: "index_credit_notes_on_policy_id"
    t.index ["previously_adjusted_amount_id"], name: "index_credit_notes_on_previously_adjusted_amount_id"
    t.index ["procurement_id"], name: "index_credit_notes_on_procurement_id"
    t.index ["sequence_id"], name: "index_credit_notes_on_sequence_id"
    t.index ["shipping_location_id"], name: "index_credit_notes_on_shipping_location_id"
    t.index ["status_id"], name: "index_credit_notes_on_status_id"
    t.index ["tax_amount_id"], name: "index_credit_notes_on_tax_amount_id"
    t.index ["tds_amount_id"], name: "index_credit_notes_on_tds_amount_id"
    t.index ["tds_rate_id"], name: "index_credit_notes_on_tds_rate_id"
    t.index ["user_id"], name: "index_credit_notes_on_user_id"
    t.index ["vendor_id"], name: "index_credit_notes_on_vendor_id"
  end

  create_table "crono_jobs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "job_id", null: false
    t.text "log", limit: 16777215
    t.datetime "last_performed_at"
    t.boolean "healthy"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_crono_jobs_on_job_id", unique: true
  end

  create_table "currencies", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "country"
    t.string "country_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "symbol"
  end

  create_table "currency_conversion_rates", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.date "date", null: false
    t.decimal "INR", precision: 20, scale: 5
    t.decimal "USD", precision: 20, scale: 5
    t.decimal "GBP", precision: 20, scale: 5
    t.decimal "EUR", precision: 20, scale: 5
    t.decimal "CAD", precision: 20, scale: 5
    t.decimal "HRK", precision: 20, scale: 5
    t.decimal "RUB", precision: 20, scale: 5
    t.decimal "BGN", precision: 20, scale: 5
    t.decimal "BRL", precision: 20, scale: 5
    t.decimal "CHF", precision: 20, scale: 5
    t.decimal "CNY", precision: 20, scale: 5
    t.decimal "CZK", precision: 20, scale: 5
    t.decimal "DKK", precision: 20, scale: 5
    t.decimal "HKD", precision: 20, scale: 5
    t.decimal "HUF", precision: 20, scale: 5
    t.decimal "IDR", precision: 20, scale: 5
    t.decimal "ILS", precision: 20, scale: 5
    t.decimal "JPY", precision: 20, scale: 5
    t.decimal "KRW", precision: 20, scale: 5
    t.decimal "MXN", precision: 20, scale: 5
    t.decimal "MYR", precision: 20, scale: 5
    t.decimal "NOK", precision: 20, scale: 5
    t.decimal "NZD", precision: 20, scale: 5
    t.decimal "PHP", precision: 20, scale: 5
    t.decimal "PLN", precision: 20, scale: 5
    t.decimal "RON", precision: 20, scale: 5
    t.decimal "SEK", precision: 20, scale: 5
    t.decimal "SGD", precision: 20, scale: 5
    t.decimal "THB", precision: 20, scale: 5
    t.decimal "TRY", precision: 20, scale: 5
    t.decimal "ZAR", precision: 20, scale: 5
    t.decimal "AUD", precision: 20, scale: 5
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "AED", precision: 20, scale: 5
    t.decimal "AFN", precision: 20, scale: 5
    t.decimal "ALL", precision: 20, scale: 5
    t.decimal "AMD", precision: 20, scale: 5
    t.decimal "ANG", precision: 20, scale: 5
    t.decimal "AOA", precision: 20, scale: 5
    t.decimal "ARS", precision: 20, scale: 5
    t.decimal "AWG", precision: 20, scale: 5
    t.decimal "AZN", precision: 20, scale: 5
    t.decimal "BAM", precision: 20, scale: 5
    t.decimal "BBD", precision: 20, scale: 5
    t.decimal "BDT", precision: 20, scale: 5
    t.decimal "BHD", precision: 20, scale: 5
    t.decimal "BIF", precision: 20, scale: 5
    t.decimal "BMD", precision: 20, scale: 5
    t.decimal "BND", precision: 20, scale: 5
    t.decimal "BOB", precision: 20, scale: 5
    t.decimal "BSD", precision: 20, scale: 5
    t.decimal "BTC", precision: 20, scale: 5
    t.decimal "BTN", precision: 20, scale: 5
    t.decimal "BWP", precision: 20, scale: 5
    t.decimal "BYN", precision: 20, scale: 5
    t.decimal "BYR", precision: 20, scale: 5
    t.decimal "BZD", precision: 20, scale: 5
    t.decimal "CDF", precision: 20, scale: 5
    t.decimal "CLF", precision: 20, scale: 5
    t.decimal "CLP", precision: 20, scale: 5
    t.decimal "COP", precision: 20, scale: 5
    t.decimal "CRC", precision: 20, scale: 5
    t.decimal "CUC", precision: 20, scale: 5
    t.decimal "CUP", precision: 20, scale: 5
    t.decimal "CVE", precision: 20, scale: 5
    t.decimal "DJF", precision: 20, scale: 5
    t.decimal "DOP", precision: 20, scale: 5
    t.decimal "DZD", precision: 20, scale: 5
    t.decimal "EEK", precision: 10, scale: 5
    t.decimal "EGP", precision: 20, scale: 5
    t.decimal "ERN", precision: 20, scale: 5
    t.decimal "ETB", precision: 20, scale: 5
    t.decimal "FJD", precision: 20, scale: 5
    t.decimal "FKP", precision: 20, scale: 5
    t.decimal "GEL", precision: 20, scale: 5
    t.decimal "GGP", precision: 20, scale: 5
    t.decimal "GHS", precision: 20, scale: 5
    t.decimal "GIP", precision: 20, scale: 5
    t.decimal "GMD", precision: 20, scale: 5
    t.decimal "GNF", precision: 20, scale: 5
    t.decimal "GTQ", precision: 20, scale: 5
    t.decimal "GYD", precision: 20, scale: 5
    t.decimal "HNL", precision: 20, scale: 5
    t.decimal "HTG", precision: 20, scale: 5
    t.decimal "IMP", precision: 20, scale: 5
    t.decimal "IQD", precision: 20, scale: 5
    t.decimal "IRR", precision: 20, scale: 5
    t.decimal "ISK", precision: 20, scale: 5
    t.decimal "JEP", precision: 20, scale: 5
    t.decimal "JMD", precision: 20, scale: 5
    t.decimal "JOD", precision: 20, scale: 5
    t.decimal "KES", precision: 20, scale: 5
    t.decimal "KGS", precision: 20, scale: 5
    t.decimal "KHR", precision: 20, scale: 5
    t.decimal "KMF", precision: 20, scale: 5
    t.decimal "KPW", precision: 20, scale: 5
    t.decimal "KWD", precision: 20, scale: 5
    t.decimal "KYD", precision: 20, scale: 5
    t.decimal "KZT", precision: 20, scale: 5
    t.decimal "LAK", precision: 20, scale: 5
    t.decimal "LBP", precision: 20, scale: 5
    t.decimal "LKR", precision: 20, scale: 5
    t.decimal "LRD", precision: 20, scale: 5
    t.decimal "LSL", precision: 20, scale: 5
    t.decimal "LTL", precision: 20, scale: 5
    t.decimal "LVL", precision: 20, scale: 5
    t.decimal "LYD", precision: 20, scale: 5
    t.decimal "MAD", precision: 20, scale: 5
    t.decimal "MDL", precision: 20, scale: 5
    t.decimal "MGA", precision: 20, scale: 5
    t.decimal "MKD", precision: 20, scale: 5
    t.decimal "MMK", precision: 20, scale: 5
    t.decimal "MNT", precision: 20, scale: 5
    t.decimal "MOP", precision: 20, scale: 5
    t.decimal "MRO", precision: 20, scale: 5
    t.decimal "MUR", precision: 20, scale: 5
    t.decimal "MVR", precision: 20, scale: 5
    t.decimal "MWK", precision: 20, scale: 5
    t.decimal "MZN", precision: 20, scale: 5
    t.decimal "NAD", precision: 20, scale: 5
    t.decimal "NGN", precision: 20, scale: 5
    t.decimal "NIO", precision: 20, scale: 5
    t.decimal "NPR", precision: 20, scale: 5
    t.decimal "OMR", precision: 20, scale: 5
    t.decimal "PAB", precision: 20, scale: 5
    t.decimal "PEN", precision: 20, scale: 5
    t.decimal "PGK", precision: 20, scale: 5
    t.decimal "PKR", precision: 20, scale: 5
    t.decimal "PYG", precision: 20, scale: 5
    t.decimal "QAR", precision: 20, scale: 5
    t.decimal "RSD", precision: 20, scale: 5
    t.decimal "RWF", precision: 20, scale: 5
    t.decimal "SAR", precision: 20, scale: 5
    t.decimal "SBD", precision: 20, scale: 5
    t.decimal "SCR", precision: 20, scale: 5
    t.decimal "SDG", precision: 20, scale: 5
    t.decimal "SHP", precision: 20, scale: 5
    t.decimal "SLL", precision: 20, scale: 5
    t.decimal "SOS", precision: 20, scale: 5
    t.decimal "SRD", precision: 20, scale: 5
    t.decimal "STD", precision: 20, scale: 5
    t.decimal "SVC", precision: 20, scale: 5
    t.decimal "SYP", precision: 20, scale: 5
    t.decimal "SZL", precision: 20, scale: 5
    t.decimal "TJS", precision: 20, scale: 5
    t.decimal "TMT", precision: 20, scale: 5
    t.decimal "TND", precision: 20, scale: 5
    t.decimal "TOP", precision: 20, scale: 5
    t.decimal "TTD", precision: 20, scale: 5
    t.decimal "TWD", precision: 20, scale: 5
    t.decimal "TZS", precision: 20, scale: 5
    t.decimal "UAH", precision: 20, scale: 5
    t.decimal "UGX", precision: 20, scale: 5
    t.decimal "UYU", precision: 20, scale: 5
    t.decimal "UZS", precision: 20, scale: 5
    t.decimal "VEF", precision: 20, scale: 5
    t.decimal "VND", precision: 20, scale: 5
    t.decimal "VUV", precision: 20, scale: 5
    t.decimal "WST", precision: 20, scale: 5
    t.decimal "XAF", precision: 20, scale: 5
    t.decimal "XAG", precision: 20, scale: 5
    t.decimal "XAU", precision: 20, scale: 5
    t.decimal "XCD", precision: 20, scale: 5
    t.decimal "XDR", precision: 20, scale: 5
    t.decimal "XOF", precision: 20, scale: 5
    t.decimal "XPF", precision: 20, scale: 5
    t.decimal "YER", precision: 20, scale: 5
    t.decimal "ZMK", precision: 20, scale: 5
    t.decimal "ZMW", precision: 20, scale: 5
    t.decimal "ZWL", precision: 20, scale: 5
    t.datetime "deleted_at"
    t.index ["date"], name: "index_currency_conversion_rates_on_date"
  end

  create_table "custom_export_configurations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "configurable_id"
    t.string "configurable_type"
    t.boolean "custom_report"
    t.boolean "custom_invoice"
    t.boolean "custom_purchase_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["configurable_id", "configurable_type"], name: "index_custom_export_configurations_on_configurable"
  end

  create_table "custom_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "field_configuration_id", null: false
    t.integer "parent_id"
    t.string "parent_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "value_id"
    t.string "value_type"
    t.integer "dependent_parent_id"
    t.string "dependent_parent_type"
    t.string "field_key"
    t.text "configured_field_value"
    t.datetime "deleted_at"
    t.index ["field_configuration_id"], name: "index_custom_fields_on_field_configuration_id"
    t.index ["parent_id"], name: "index_custom_fields_on_parent_id"
    t.index ["parent_type"], name: "index_custom_fields_on_parent_type"
    t.index ["value_id", "value_type"], name: "index_custom_fields_on_value_id_and_value_type"
  end

  create_table "customer_account_transactions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "customer_account_id"
    t.string "transaction_type"
    t.integer "transaction_amount_id"
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "associated_object_id"
    t.string "associated_object_type"
    t.datetime "deleted_at"
    t.index ["associated_object_type", "associated_object_id"], name: "indx_cstmer_acc_tranxs_on_assoc_acc_type_and_assoc_acc_id"
    t.index ["customer_account_id"], name: "index_customer_account_transactions_on_customer_account_id"
    t.index ["transaction_amount_id"], name: "index_customer_account_transactions_on_transaction_amount_id"
  end

  create_table "customer_accounts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "customer_id"
    t.integer "balance_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["balance_id"], name: "index_customer_accounts_on_balance_id"
    t.index ["customer_id"], name: "index_customer_accounts_on_customer_id"
  end

  create_table "customer_attachments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "attached_file_file_name"
    t.string "attached_file_content_type"
    t.integer "attached_file_file_size"
    t.datetime "attached_file_updated_at"
    t.integer "customer_id"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["customer_id"], name: "index_customer_attachments_on_customer_id"
  end

  create_table "customers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "mobile_number"
    t.text "description"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "gst"
    t.string "pan"
    t.integer "created_by_id"
    t.boolean "active", default: true
    t.boolean "is_deleted", default: false
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_customers_on_company_id"
    t.index ["created_by_id"], name: "index_customers_on_created_by_id"
    t.index ["deleted_at"], name: "index_customers_on_deleted_at"
  end

  create_table "delivery_challans", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "company_id"
    t.integer "user_id"
    t.integer "procurement_id"
    t.integer "location_id"
    t.integer "delivery_location_id"
    t.integer "vendor_id"
    t.integer "payment_term_id"
    t.integer "procurement_term_id"
    t.integer "document_status_id"
    t.string "doc_number"
    t.boolean "override_doc_number"
    t.string "prefix"
    t.string "sequence_start"
    t.date "date"
    t.date "challan_date"
    t.date "due_date"
    t.boolean "roundoff_total_enabled"
    t.decimal "roundoff_amount", precision: 10, scale: 5
    t.integer "transaction_amount_id"
    t.integer "total_before_tax_id"
    t.integer "tax_amount_id"
    t.integer "total_after_tax_id"
    t.integer "discount_amount_id"
    t.integer "balance_amount_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_deleted", default: false, null: false
    t.datetime "deleted_at"
    t.index ["balance_amount_id"], name: "index_delivery_challans_on_balance_amount_id"
    t.index ["company_id"], name: "index_delivery_challans_on_company_id"
    t.index ["deleted_at"], name: "index_delivery_challans_on_deleted_at"
    t.index ["delivery_location_id"], name: "index_delivery_challans_on_delivery_location_id"
    t.index ["discount_amount_id"], name: "index_delivery_challans_on_discount_amount_id"
    t.index ["document_status_id"], name: "index_delivery_challans_on_document_status_id"
    t.index ["location_id"], name: "index_delivery_challans_on_location_id"
    t.index ["payment_term_id"], name: "index_delivery_challans_on_payment_term_id"
    t.index ["procurement_id"], name: "index_delivery_challans_on_procurement_id"
    t.index ["procurement_term_id"], name: "index_delivery_challans_on_procurement_term_id"
    t.index ["tax_amount_id"], name: "index_delivery_challans_on_tax_amount_id"
    t.index ["total_after_tax_id"], name: "index_delivery_challans_on_total_after_tax_id"
    t.index ["total_before_tax_id"], name: "index_delivery_challans_on_total_before_tax_id"
    t.index ["transaction_amount_id"], name: "index_delivery_challans_on_transaction_amount_id"
    t.index ["user_id"], name: "index_delivery_challans_on_user_id"
    t.index ["vendor_id"], name: "index_delivery_challans_on_vendor_id"
  end

  create_table "departments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_deleted", default: false, null: false
    t.string "ancestry"
    t.integer "cost_center_id"
    t.datetime "deleted_at"
    t.string "department_code"
    t.string "code"
    t.string "gl_code"
    t.index ["ancestry"], name: "index_departments_on_ancestry"
    t.index ["company_id"], name: "index_departments_on_company_id"
    t.index ["cost_center_id"], name: "index_departments_on_cost_center_id"
    t.index ["deleted_at"], name: "index_departments_on_deleted_at"
  end

  create_table "desktop_users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "email", null: false
    t.string "country", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "distance_expense_configs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "enabled"
    t.integer "default_category_id"
    t.integer "rate_id"
    t.integer "distance_unit_id"
    t.integer "policy_id", null: false
    t.boolean "enforce_category", default: false
    t.datetime "deleted_at"
    t.index ["default_category_id"], name: "index_distance_expense_configs_on_default_category_id"
    t.index ["policy_id"], name: "index_distance_expense_configs_on_policy_id"
    t.index ["rate_id"], name: "index_distance_expense_configs_on_rate_id"
  end

  create_table "distance_expense_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_distance_expense_types_on_name"
  end

  create_table "distance_expenses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "expense_id"
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "distance_id"
    t.integer "maps_distance_id"
    t.integer "type_id"
    t.decimal "odometer_reading_start", precision: 10, scale: 2
    t.decimal "odometer_reading_end", precision: 10, scale: 2
    t.integer "odometer_reading_receipt_start_id"
    t.integer "odometer_reading_receipt_end_id"
    t.integer "vehicle_rate_id"
    t.integer "distance_rate_id"
    t.integer "distance_unit_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_distance_expenses_on_deleted_at"
    t.index ["distance_id"], name: "index_distance_expenses_on_distance_id"
    t.index ["distance_rate_id"], name: "index_distance_expenses_on_distance_rate_id"
    t.index ["distance_unit_id"], name: "index_distance_expenses_on_distance_unit_id"
    t.index ["expense_id"], name: "index_distance_expenses_on_expense_id"
    t.index ["maps_distance_id"], name: "index_distance_expenses_on_maps_distance_id"
    t.index ["odometer_reading_receipt_end_id"], name: "index_distance_expenses_on_odometer_reading_receipt_end_id"
    t.index ["odometer_reading_receipt_start_id"], name: "index_distance_expenses_on_odometer_reading_receipt_start_id"
    t.index ["type_id"], name: "index_distance_expenses_on_type_id"
    t.index ["vehicle_rate_id"], name: "index_distance_expenses_on_vehicle_rate_id"
  end

  create_table "distances", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.decimal "value", precision: 10, scale: 4
    t.integer "physical_unit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["physical_unit_id"], name: "index_distances_on_physical_unit_id"
  end

  create_table "document_items", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "parent_document_id", null: false
    t.string "parent_document_type", null: false
    t.integer "inventory_line_item_id"
    t.string "description"
    t.string "hsn_sac"
    t.decimal "quantity", precision: 20, scale: 5
    t.decimal "rate", precision: 20, scale: 5
    t.decimal "tax", precision: 20, scale: 5, default: "0.0"
    t.decimal "tds", precision: 20, scale: 5, default: "0.0"
    t.decimal "discount", precision: 20, scale: 5, default: "0.0"
    t.integer "tax_amount_id"
    t.integer "tds_amount_id"
    t.integer "discount_amount_id"
    t.integer "total_amount_id"
    t.date "delivery_date"
    t.string "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "purchase_order_item_id"
    t.string "product_id"
    t.datetime "deleted_at"
    t.index ["discount_amount_id"], name: "index_document_items_on_discount_amount_id"
    t.index ["inventory_line_item_id"], name: "index_document_items_on_inventory_line_item_id"
    t.index ["parent_document_type", "parent_document_id"], name: "indx_doc_items_on_parent_doc_type_and_parent_doc_id"
    t.index ["purchase_order_item_id"], name: "index_document_items_on_purchase_order_item_id"
    t.index ["tax_amount_id"], name: "index_document_items_on_tax_amount_id"
    t.index ["tds_amount_id"], name: "index_document_items_on_tds_amount_id"
    t.index ["total_amount_id"], name: "index_document_items_on_total_amount_id"
  end

  create_table "document_level_reviewer_mappings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "policy_id"
    t.integer "level_id"
    t.integer "reviewer_id"
    t.integer "document_reviewer_mappable_id", null: false
    t.string "document_reviewer_mappable_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "level_number"
    t.boolean "taken_control", default: false
    t.integer "taken_control_by_id"
    t.boolean "viewable", default: false
    t.integer "action_taken_by_id"
    t.integer "action_id"
    t.string "provider_name"
    t.decimal "threshold", precision: 20, scale: 5
    t.boolean "active", default: true
    t.boolean "wo_exception", default: true
    t.boolean "forwarded", default: false
    t.integer "forwarded_by_id"
    t.integer "forwarded_to_id"
    t.decimal "min", precision: 20, scale: 5, default: "0.0"
    t.decimal "max", precision: 20, scale: 5
    t.integer "rejected_by_id"
    t.datetime "action_taken_at"
    t.datetime "deleted_at"
    t.index ["action_id"], name: "index_document_level_reviewer_mappings_on_action_id"
    t.index ["action_taken_by_id"], name: "index_document_level_reviewer_mappings_on_action_taken_by_id"
    t.index ["document_reviewer_mappable_type", "document_reviewer_mappable_id"], name: "indx_doc_lvl_rvwr_mpng_on_doc_rvwr_mpble_tp_n_doc_rvwr_mpble_id"
    t.index ["document_reviewer_mappable_type", "provider_name", "policy_id"], name: "index_dlrm_provider_policy_mappable_type"
    t.index ["forwarded"], name: "index_document_level_reviewer_mappings_on_forwarded"
    t.index ["forwarded_by_id"], name: "index_document_level_reviewer_mappings_on_forwarded_by_id"
    t.index ["forwarded_to_id"], name: "index_document_level_reviewer_mappings_on_forwarded_to_id"
    t.index ["level_id"], name: "index_document_level_reviewer_mappings_on_level_id"
    t.index ["level_number"], name: "index_document_level_reviewer_mappings_on_level_number"
    t.index ["policy_id"], name: "index_document_level_reviewer_mappings_on_policy_id"
    t.index ["rejected_by_id"], name: "index_document_level_reviewer_mappings_on_rejected_by_id"
    t.index ["reviewer_id"], name: "index_document_level_reviewer_mappings_on_reviewer_id"
    t.index ["taken_control"], name: "index_document_level_reviewer_mappings_on_taken_control"
    t.index ["taken_control_by_id"], name: "index_document_level_reviewer_mappings_on_taken_control_by_id"
    t.index ["viewable"], name: "index_document_level_reviewer_mappings_on_viewable"
  end

  create_table "document_message_receipts", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "receiptable_document_id", null: false
    t.string "receiptable_document_type", null: false
    t.integer "document_message_id", null: false
    t.datetime "browser_push_sent_at"
    t.datetime "app_push_sent_at"
    t.datetime "email_sent_at"
    t.datetime "read_at"
    t.datetime "trashed_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_push_sent_at"], name: "index_document_message_receipts_on_app_push_sent_at"
    t.index ["browser_push_sent_at"], name: "index_document_message_receipts_on_browser_push_sent_at"
    t.index ["deleted_at"], name: "index_document_message_receipts_on_deleted_at"
    t.index ["document_message_id"], name: "index_document_message_receipts_on_document_message_id"
    t.index ["email_sent_at"], name: "index_document_message_receipts_on_email_sent_at"
    t.index ["read_at"], name: "index_document_message_receipts_on_read_at"
    t.index ["receiptable_document_id"], name: "index_document_message_receipts_on_receiptable_document_id"
    t.index ["receiptable_document_type"], name: "index_document_message_receipts_on_receiptable_document_type"
    t.index ["trashed_at"], name: "index_document_message_receipts_on_trashed_at"
    t.index ["user_id"], name: "index_document_message_receipts_on_user_id"
  end

  create_table "document_message_types", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_document_message_types_on_name"
  end

  create_table "document_messages", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "order"
    t.integer "user_id"
    t.integer "type_id"
    t.text "body"
    t.string "attachment_file_name"
    t.string "attachment_content_type"
    t.bigint "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "deleted_at"
    t.datetime "trashed_at"
    t.integer "messageable_document_id", null: false
    t.string "messageable_document_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_document_messages_on_deleted_at"
    t.index ["messageable_document_id"], name: "index_document_messages_on_messageable_document_id"
    t.index ["messageable_document_type"], name: "index_document_messages_on_messageable_document_type"
    t.index ["order"], name: "index_document_messages_on_order"
    t.index ["trashed_at"], name: "index_document_messages_on_trashed_at"
    t.index ["type_id"], name: "index_document_messages_on_type_id"
    t.index ["user_id"], name: "index_document_messages_on_user_id"
  end

  create_table "document_number_config_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "document_number_configs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "prefix"
    t.string "sequence_start"
    t.integer "company_id"
    t.integer "document_number_config_type_id"
    t.integer "purpose_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_document_number_configs_on_company_id"
    t.index ["document_number_config_type_id"], name: "index_document_number_configs_on_document_number_config_type_id"
    t.index ["purpose_id"], name: "index_document_number_configs_on_purpose_id"
  end

  create_table "document_slices", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "page_number"
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.integer "receipt_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["receipt_id"], name: "index_document_slices_on_receipt_id"
  end

  create_table "document_statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "duplicate_expense_mappings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "expense_id", null: false
    t.integer "duplicate_expense_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["duplicate_expense_id"], name: "index_duplicate_expense_mappings_on_duplicate_expense_id"
    t.index ["expense_id"], name: "index_duplicate_expense_mappings_on_expense_id"
  end

  create_table "e_way_bills", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "company_id"
    t.integer "user_id"
    t.integer "procurement_id"
    t.integer "location_id"
    t.integer "delivery_location_id"
    t.integer "vendor_id"
    t.integer "payment_term_id"
    t.integer "procurement_term_id"
    t.string "doc_number"
    t.date "date"
    t.string "generated_by"
    t.datetime "valid_from"
    t.datetime "valid_to"
    t.string "ref_doc_name"
    t.string "ref_doc_date"
    t.integer "amount_id"
    t.string "hsn_code"
    t.string "reason_for_transportation"
    t.string "mode"
    t.string "vehicle_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_deleted", default: false, null: false
    t.datetime "deleted_at"
    t.index ["amount_id"], name: "index_e_way_bills_on_amount_id"
    t.index ["company_id"], name: "index_e_way_bills_on_company_id"
    t.index ["deleted_at"], name: "index_e_way_bills_on_deleted_at"
    t.index ["delivery_location_id"], name: "index_e_way_bills_on_delivery_location_id"
    t.index ["location_id"], name: "index_e_way_bills_on_location_id"
    t.index ["payment_term_id"], name: "index_e_way_bills_on_payment_term_id"
    t.index ["procurement_id"], name: "index_e_way_bills_on_procurement_id"
    t.index ["procurement_term_id"], name: "index_e_way_bills_on_procurement_term_id"
    t.index ["user_id"], name: "index_e_way_bills_on_user_id"
    t.index ["vendor_id"], name: "index_e_way_bills_on_vendor_id"
  end

  create_table "email_authorizations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "authorizable_id", null: false
    t.string "authorizable_type", null: false
    t.string "token"
    t.boolean "is_valid", default: true
    t.integer "view_role_id"
    t.datetime "deleted_at"
    t.index ["authorizable_id"], name: "index_email_authorizations_on_authorizable_id"
    t.index ["authorizable_type"], name: "index_email_authorizations_on_authorizable_type"
    t.index ["token"], name: "index_email_authorizations_on_token"
    t.index ["user_id"], name: "index_email_authorizations_on_user_id"
  end

  create_table "email_events", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "email_id", null: false
    t.string "event", null: false
    t.string "link"
    t.datetime "received_at"
    t.string "event_id"
    t.text "payload", limit: 4294967295
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["email_id"], name: "index_email_events_on_email_id"
    t.index ["event"], name: "index_email_events_on_event"
    t.index ["event_id"], name: "index_email_events_on_event_id"
    t.index ["link"], name: "index_email_events_on_link"
    t.index ["received_at"], name: "index_email_events_on_received_at"
  end

  create_table "emails", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "entity_type"
    t.bigint "entity_id"
    t.integer "company_id"
    t.string "message_id"
    t.string "sender"
    t.string "recipient"
    t.string "bcc"
    t.string "cc"
    t.string "subject"
    t.text "body", limit: 4294967295
    t.string "mailer_klass"
    t.string "mailer_action"
    t.string "configuration_set"
    t.datetime "sent_at"
    t.datetime "delivered_at"
    t.integer "delivery_count"
    t.datetime "last_opened_at"
    t.integer "open_count"
    t.datetime "last_link_clicked_at"
    t.integer "link_open_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["bcc"], name: "index_emails_on_bcc"
    t.index ["cc"], name: "index_emails_on_cc"
    t.index ["company_id"], name: "index_emails_on_company_id"
    t.index ["delivered_at"], name: "index_emails_on_delivered_at"
    t.index ["delivery_count"], name: "index_emails_on_delivery_count"
    t.index ["entity_type", "entity_id"], name: "index_emails_on_entity_type_and_entity_id"
    t.index ["last_link_clicked_at"], name: "index_emails_on_last_link_clicked_at"
    t.index ["last_opened_at"], name: "index_emails_on_last_opened_at"
    t.index ["link_open_count"], name: "index_emails_on_link_open_count"
    t.index ["mailer_action"], name: "index_emails_on_mailer_action"
    t.index ["mailer_klass"], name: "index_emails_on_mailer_klass"
    t.index ["message_id"], name: "index_emails_on_message_id"
    t.index ["open_count"], name: "index_emails_on_open_count"
    t.index ["recipient"], name: "index_emails_on_recipient"
    t.index ["sender"], name: "index_emails_on_sender"
    t.index ["sent_at"], name: "index_emails_on_sent_at"
    t.index ["subject"], name: "index_emails_on_subject"
  end

  create_table "enforce_budget_configurations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.boolean "enforce_purchase_order_budget"
    t.boolean "enforce_payment_budget"
    t.boolean "enforce_expense_budget"
    t.boolean "enforce_invoice_budget"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_enforce_budget_configurations_on_company_id"
  end

  create_table "enforce_policies", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "enforceable_id", null: false
    t.string "enforceable_type", null: false
    t.boolean "enabled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["enforceable_type", "enforceable_id"], name: "index_enforce_policies_on_enforceable_type_and_enforceable_id"
  end

  create_table "expense_data_extract_sources", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "expense_data_extract_statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "expense_data_extracts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "merchant"
    t.string "reference_id"
    t.time "time"
    t.integer "amount_id"
    t.integer "category_id"
    t.integer "sourcable_id"
    t.string "sourcable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "extractable_id", null: false
    t.string "extractable_type", null: false
    t.text "note"
    t.datetime "datetime"
    t.integer "expense_data_extract_source_id"
    t.integer "status_id", null: false
    t.datetime "deleted_at"
    t.index ["amount_id"], name: "index_expense_data_extracts_on_amount_id"
    t.index ["category_id"], name: "index_expense_data_extracts_on_category_id"
    t.index ["expense_data_extract_source_id"], name: "index_expense_data_extracts_on_expense_data_extract_source_id"
    t.index ["extractable_id", "extractable_type"], name: "index_expense_data_extracts_on_extractable"
    t.index ["sourcable_id"], name: "index_expense_data_extracts_on_sourcable_id"
    t.index ["sourcable_type"], name: "index_expense_data_extracts_on_sourcable_type"
    t.index ["status_id"], name: "index_expense_data_extracts_on_status_id"
  end

  create_table "expense_rule_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "expense_rules", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "greater_than_amount_id"
    t.integer "category_id"
    t.integer "days_after"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rule_type_id"
    t.integer "expense_rule_type_id"
    t.integer "policy_id"
    t.boolean "is_deleted", default: false
    t.datetime "deleted_at"
    t.index ["category_id"], name: "index_expense_rules_on_category_id"
    t.index ["deleted_at"], name: "index_expense_rules_on_deleted_at"
    t.index ["expense_rule_type_id"], name: "index_expense_rules_on_expense_rule_type_id"
    t.index ["greater_than_amount_id"], name: "index_expense_rules_on_greater_than_amount_id"
    t.index ["policy_id"], name: "index_expense_rules_on_policy_id"
    t.index ["rule_type_id"], name: "index_expense_rules_on_rule_type_id"
  end

  create_table "expense_statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "expense_tax_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_expense_tax_types_on_name"
  end

  create_table "expense_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "expenses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "amount_id"
    t.integer "expense_status_id"
    t.text "note"
    t.date "date"
    t.integer "user_id"
    t.integer "expense_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "manager_memo"
    t.integer "rejecting_manager_id"
    t.integer "report_id"
    t.integer "category_id"
    t.boolean "is_deleted", default: false, null: false
    t.boolean "transcribed", default: false
    t.boolean "personal", default: false
    t.boolean "reimbursable"
    t.boolean "synced_with_quickbooks", default: false
    t.string "split_link"
    t.boolean "deleted_to_split", default: false
    t.boolean "from_cash_on_hand", default: false
    t.boolean "cash_on_hand_blocked"
    t.integer "expense_tax_type_id"
    t.decimal "gst_percentage", precision: 10, scale: 5
    t.decimal "tds_percentage", precision: 10, scale: 5
    t.integer "tds_amount_id"
    t.integer "gst_type_id"
    t.integer "tds_slab_id"
    t.integer "gst_amount_id"
    t.datetime "usage_date_start"
    t.datetime "usage_date_end"
    t.string "usage_date_type"
    t.integer "spent_from_id"
    t.boolean "custom_conversion_rate", default: false
    t.integer "cost_center_id"
    t.integer "created_by_id"
    t.integer "modified_by_id"
    t.datetime "deleted_at"
    t.integer "gstin_location_id"
    t.integer "state_of_expense_id"
    t.string "hsn_sac"
    t.string "merchant_bill_no"
    t.integer "tax_rate_id"
    t.index ["amount_id"], name: "index_expenses_on_amount_id"
    t.index ["category_id"], name: "index_expenses_on_category_id"
    t.index ["created_at"], name: "index_expenses_on_created_at"
    t.index ["created_by_id"], name: "index_expenses_on_created_by_id"
    t.index ["deleted_at"], name: "index_expenses_on_deleted_at"
    t.index ["expense_status_id"], name: "index_expenses_on_expense_status_id"
    t.index ["expense_tax_type_id"], name: "index_expenses_on_expense_tax_type_id"
    t.index ["expense_type_id"], name: "index_expenses_on_expense_type_id"
    t.index ["gst_amount_id"], name: "index_expenses_on_gst_amount_id"
    t.index ["gst_type_id"], name: "index_expenses_on_gst_type_id"
    t.index ["modified_by_id"], name: "index_expenses_on_modified_by_id"
    t.index ["rejecting_manager_id"], name: "index_expenses_on_rejecting_manager_id"
    t.index ["report_id"], name: "index_expenses_on_report_id"
    t.index ["spent_from_id"], name: "index_expenses_on_spent_from_id"
    t.index ["tds_amount_id"], name: "index_expenses_on_tds_amount_id"
    t.index ["tds_slab_id"], name: "index_expenses_on_tds_slab_id"
    t.index ["user_id"], name: "index_expenses_on_user_id"
  end

  create_table "export_config_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_export_config_types_on_name"
  end

  create_table "export_configs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "export_config_type_id", null: false
    t.integer "field_reference_id"
    t.string "field_reference_type"
    t.integer "order"
    t.string "field_name"
    t.boolean "spreadsheet", default: true
    t.boolean "pdf", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_export_configs_on_company_id"
    t.index ["export_config_type_id"], name: "index_export_configs_on_export_config_type_id"
  end

  create_table "export_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "export_job_statuses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_export_job_statuses_on_created_at"
    t.index ["name"], name: "index_export_job_statuses_on_name"
    t.index ["updated_at"], name: "index_export_job_statuses_on_updated_at"
  end

  create_table "export_jobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "export_type"
    t.integer "created_by_id"
    t.bigint "company_id", null: false
    t.text "request_params", limit: 4294967295
    t.datetime "completed_at"
    t.integer "total_records"
    t.integer "completed_records"
    t.integer "completion_percentage"
    t.string "attachment_file_name"
    t.string "attachment_content_type"
    t.bigint "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status_id", null: false
    t.datetime "deleted_at"
    t.string "master"
    t.string "description"
    t.string "record_type"
    t.bigint "record_id"
    t.text "crash_stacktrace"
    t.text "message"
    t.text "note"
    t.index ["company_id"], name: "index_export_jobs_on_company_id"
    t.index ["completed_at"], name: "index_export_jobs_on_completed_at"
    t.index ["completed_records"], name: "index_export_jobs_on_completed_records"
    t.index ["completion_percentage"], name: "index_export_jobs_on_completion_percentage"
    t.index ["created_at"], name: "index_export_jobs_on_created_at"
    t.index ["created_by_id"], name: "index_export_jobs_on_created_by_id"
    t.index ["export_type"], name: "index_export_jobs_on_export_type"
    t.index ["name"], name: "index_export_jobs_on_name"
    t.index ["record_type", "record_id"], name: "index_export_jobs_on_record_type_and_record_id"
    t.index ["total_records"], name: "index_export_jobs_on_total_records"
    t.index ["updated_at"], name: "index_export_jobs_on_updated_at"
  end

  create_table "export_preferences", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "export_field_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_export_preferences_on_company_id"
    t.index ["export_field_id"], name: "index_export_preferences_on_export_field_id"
  end

  create_table "export_requests", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "model_class"
    t.string "export_name"
    t.integer "export_template_id", null: false
    t.string "file_file_name"
    t.string "file_content_type"
    t.bigint "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "scheduled_on"
    t.datetime "expires_on"
    t.integer "user_id", null: false
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_export_requests_on_company_id"
    t.index ["expires_on"], name: "index_export_requests_on_expires_on"
    t.index ["export_name"], name: "index_export_requests_on_export_name"
    t.index ["export_template_id"], name: "index_export_requests_on_export_template_id"
    t.index ["model_class"], name: "index_export_requests_on_model_class"
    t.index ["scheduled_on"], name: "index_export_requests_on_scheduled_on"
    t.index ["user_id"], name: "index_export_requests_on_user_id"
  end

  create_table "export_templates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "template_type", null: false
    t.text "configuration", limit: 4294967295
    t.string "model_class", null: false
    t.boolean "active", default: true
    t.boolean "personal"
    t.integer "created_by_user_id", null: false
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["active"], name: "index_export_templates_on_active"
    t.index ["company_id"], name: "index_export_templates_on_company_id"
    t.index ["created_by_user_id"], name: "index_export_templates_on_created_by_user_id"
    t.index ["model_class"], name: "index_export_templates_on_model_class"
    t.index ["name"], name: "index_export_templates_on_name"
    t.index ["personal"], name: "index_export_templates_on_personal"
    t.index ["template_type"], name: "index_export_templates_on_template_type"
  end

  create_table "feature_subscriptions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "subscribable_id", null: false
    t.string "subscribable_type", null: false
    t.boolean "ocr_enabled", default: false, null: false
    t.boolean "expense_management_enabled", default: false, null: false
    t.boolean "gift_card_enabled", default: false, null: false
    t.boolean "gift_voucher_enabled", default: false, null: false
    t.boolean "meal_card_enabled", default: false, null: false
    t.boolean "fuel_card_enabled", default: false, null: false
    t.boolean "medical_card_enabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "expense_card_enabled", default: false
    t.boolean "reimbursement_card_enabled", default: false
    t.boolean "hard_copy_receipt", default: false
    t.boolean "itz_cash_d_code_enabled", default: false
    t.boolean "yes_bank_account"
    t.boolean "bank_account_reimbursement"
    t.boolean "payroll_card_enabled", default: false
    t.boolean "current_account_connected"
    t.boolean "invoicing_system", default: false
    t.boolean "travel_request", default: false
    t.boolean "budgeting_system", default: false
    t.boolean "em_tax_tracking", default: false
    t.boolean "procurement", default: false
    t.boolean "custom_currency_conversion", default: false
    t.boolean "vendor_empanelment_workflow", default: false
    t.boolean "purchase_requisition_system"
    t.string "bank_service_provider"
    t.boolean "group_entity_structure", default: false
    t.boolean "agreement_based_payment_system", default: false
    t.boolean "grn_enabled", default: true
    t.boolean "srn_enabled", default: false
    t.boolean "vendor_portal", default: false
    t.boolean "gstin_verification_enabled", default: false
    t.boolean "request_encryption_enabled", default: false
    t.boolean "user_level_custom_fields", default: false
    t.boolean "utility_bills_enabled", default: false
    t.boolean "analytics_system"
    t.datetime "deleted_at"
    t.index ["grn_enabled"], name: "index_feature_subscriptions_on_grn_enabled"
    t.index ["srn_enabled"], name: "index_feature_subscriptions_on_srn_enabled"
    t.index ["subscribable_id"], name: "index_feature_subscriptions_on_subscribable_id"
    t.index ["subscribable_type"], name: "index_feature_subscriptions_on_subscribable_type"
    t.index ["vendor_portal"], name: "index_feature_subscriptions_on_vendor_portal"
  end

  create_table "feedback_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "feedbacks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "feedback_type_id", null: false
    t.text "content", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["feedback_type_id"], name: "index_feedbacks_on_feedback_type_id"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "field_amounts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "value_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["value_id"], name: "index_field_amounts_on_value_id"
  end

  create_table "field_booleans", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.boolean "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "field_configurations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.boolean "enabled", default: true, null: false
    t.integer "field_type_id", null: false
    t.boolean "mandatory", default: false, null: false
    t.integer "company_id", null: false
    t.integer "configurable_id"
    t.string "configurable_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "field_name", null: false
    t.integer "default_value_id"
    t.string "default_value_type"
    t.boolean "is_deleted", default: false, null: false
    t.boolean "global", default: true
    t.string "external_reference_type"
    t.integer "external_reference_id"
    t.integer "parent_id"
    t.string "parent_type"
    t.boolean "root_field", default: true
    t.string "field_key"
    t.integer "sequence_number"
    t.datetime "deleted_at"
    t.boolean "printable", default: true
    t.index ["company_id"], name: "index_field_configurations_on_company_id"
    t.index ["configurable_id"], name: "index_field_configurations_on_configurable_id"
    t.index ["configurable_type"], name: "index_field_configurations_on_configurable_type"
    t.index ["default_value_id", "default_value_type"], name: "index_field_configurations_on_default_value"
    t.index ["deleted_at"], name: "index_field_configurations_on_deleted_at"
    t.index ["external_reference_id", "external_reference_type"], name: "index_field_configurations_on_external_reference"
    t.index ["field_type_id"], name: "index_field_configurations_on_field_type_id"
    t.index ["parent_id", "parent_type"], name: "index_field_configurations_on_parent_id_and_parent_type"
    t.index ["sequence_number"], name: "index_field_configurations_on_sequence_number"
  end

  create_table "field_customizations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "class_name", null: false
    t.string "field_name", null: false
    t.boolean "enabled", default: false, null: false
    t.boolean "presence", default: false, null: false
    t.boolean "show_in_pdf", default: false, null: false
    t.integer "scopable_id", null: false
    t.string "scopable_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["class_name"], name: "index_field_customizations_on_class_name"
    t.index ["enabled"], name: "index_field_customizations_on_enabled"
    t.index ["field_name"], name: "index_field_customizations_on_field_name"
    t.index ["presence"], name: "index_field_customizations_on_presence"
    t.index ["scopable_type", "scopable_id"], name: "index_field_customizations_on_scopable_type_and_scopable_id"
    t.index ["show_in_pdf"], name: "index_field_customizations_on_show_in_pdf"
  end

  create_table "field_date_times", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.datetime "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "field_dates", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.date "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "field_decimals", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "field_drop_down_items", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.integer "field_configuration_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_deleted", default: false
    t.string "field_key"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_field_drop_down_items_on_deleted_at"
    t.index ["field_configuration_id"], name: "index_field_drop_down_items_on_field_configuration_id"
  end

  create_table "field_drop_down_selections", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "value_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["value_id"], name: "index_field_drop_down_selections_on_value_id"
  end

  create_table "field_multiselect_items", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "field_configuration_id"
    t.boolean "is_deleted"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_field_multiselect_items_on_deleted_at"
    t.index ["field_configuration_id"], name: "index_field_multiselect_items_on_field_configuration_id"
  end

  create_table "field_multiselect_selection_items", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "value_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "field_multiselect_selection_id"
    t.datetime "deleted_at"
    t.index ["field_multiselect_selection_id"], name: "index_field_multiselect_selection_items_on_selection_id"
    t.index ["value_id"], name: "index_field_multiselect_selection_items_on_value_id"
  end

  create_table "field_multiselect_selections", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "field_numbers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "field_parent_mappings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "field_configuration_id", null: false
    t.integer "field_parent_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["field_configuration_id"], name: "index_field_parent_mappings_on_field_configuration_id"
    t.index ["field_parent_type_id"], name: "index_field_parent_mappings_on_field_parent_type_id"
  end

  create_table "field_parent_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "field_texts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "field_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "finly_transactions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "finly_account_id", null: false
    t.string "finly_account_type", null: false
    t.integer "transaction_type_id", null: false
    t.integer "amount_id", null: false
    t.string "transaction_reference_id", null: false
    t.integer "status_id", null: false
    t.integer "payment_purpose_id", null: false
    t.integer "opening_balance_id"
    t.integer "closing_balance_id"
    t.integer "associated_transaction_id"
    t.string "associated_transaction_type"
    t.integer "payment_id"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "date"
    t.integer "sequence_number"
    t.datetime "deleted_at"
    t.index ["amount_id"], name: "index_finly_transactions_on_amount_id"
    t.index ["associated_transaction_id"], name: "index_finly_transactions_on_associated_transaction_id"
    t.index ["associated_transaction_type"], name: "index_finly_transactions_on_associated_transaction_type"
    t.index ["closing_balance_id"], name: "index_finly_transactions_on_closing_balance_id"
    t.index ["company_id"], name: "index_finly_transactions_on_company_id"
    t.index ["date"], name: "index_finly_transactions_on_date"
    t.index ["finly_account_id"], name: "index_finly_transactions_on_finly_account_id"
    t.index ["finly_account_type"], name: "index_finly_transactions_on_finly_account_type"
    t.index ["opening_balance_id"], name: "index_finly_transactions_on_opening_balance_id"
    t.index ["payment_id"], name: "index_finly_transactions_on_payment_id"
    t.index ["payment_purpose_id"], name: "index_finly_transactions_on_payment_purpose_id"
    t.index ["sequence_number"], name: "index_finly_transactions_on_sequence_number"
    t.index ["status_id"], name: "index_finly_transactions_on_status_id"
    t.index ["transaction_reference_id"], name: "index_finly_transactions_on_transaction_reference_id"
    t.index ["transaction_type_id"], name: "index_finly_transactions_on_transaction_type_id"
  end

  create_table "form_dependencies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "dependency_type_id", null: false
    t.integer "controlling_user_id", null: false
    t.integer "controlling_entity_id", null: false
    t.integer "dependent_entity_id", null: false
    t.integer "created_by_id", null: false
    t.integer "updated_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_form_dependencies_on_company_id"
    t.index ["controlling_entity_id"], name: "index_form_dependencies_on_controlling_entity_id"
    t.index ["controlling_user_id"], name: "index_form_dependencies_on_controlling_user_id"
    t.index ["created_by_id"], name: "index_form_dependencies_on_created_by_id"
    t.index ["dependency_type_id"], name: "index_form_dependencies_on_dependency_type_id"
    t.index ["dependent_entity_id"], name: "index_form_dependencies_on_dependent_entity_id"
    t.index ["updated_by_id"], name: "index_form_dependencies_on_updated_by_id"
  end

  create_table "form_dependency_choice_mappings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "form_dependency_choice_id", null: false
    t.integer "dependent_choice_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_form_dependency_choice_mappings_on_company_id"
    t.index ["dependent_choice_id"], name: "index_form_dependency_choice_mappings_on_dependent_choice_id"
    t.index ["form_dependency_choice_id"], name: "index_form_dependency_choice_mappings_form_dependency_choice_id"
  end

  create_table "form_dependency_choices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "form_dependency_id", null: false
    t.integer "controlling_choice_id", null: false
    t.boolean "is_choice_selected"
    t.boolean "dependent_entity_required"
    t.boolean "dependent_entity_visible"
    t.boolean "dependent_entity_editable"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_form_dependency_choices_on_company_id"
    t.index ["controlling_choice_id"], name: "index_form_dependency_choices_on_controlling_choice_id"
    t.index ["form_dependency_id"], name: "index_form_dependency_choices_on_form_dependency_id"
  end

  create_table "form_dependency_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_form_dependency_types_on_name"
  end

  create_table "form_entities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "uuid", limit: 36, null: false
    t.integer "company_id", null: false
    t.string "form_id", limit: 36, null: false
    t.string "form_section_id", limit: 36, null: false
    t.integer "created_by_user_id"
    t.string "field_key", null: false
    t.string "label"
    t.string "placeholder"
    t.string "hint"
    t.string "field_type"
    t.string "default_value"
    t.boolean "multiple"
    t.boolean "editable"
    t.boolean "required"
    t.boolean "active"
    t.boolean "unique"
    t.boolean "visible"
    t.integer "position"
    t.boolean "custom_field"
    t.boolean "dependent"
    t.boolean "conditional_required"
    t.boolean "can_visible_be_changed"
    t.boolean "can_editable_be_changed"
    t.boolean "can_required_be_changed"
    t.boolean "can_uniqueness_be_changed"
    t.boolean "can_be_disabled"
    t.boolean "can_label_be_renamed"
    t.boolean "can_not_be_hidden"
    t.boolean "can_be_filtered"
    t.boolean "can_choices_be_changed"
    t.boolean "show_in_bulk_import"
    t.boolean "allow_sort_in_filter"
    t.boolean "allow_clearing_default_value"
    t.text "options"
    t.text "chained"
    t.text "data_provider"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_form_entities_on_company_id"
    t.index ["created_at"], name: "index_form_entities_on_created_at"
    t.index ["created_by_user_id"], name: "index_form_entities_on_created_by_user_id"
    t.index ["deleted_at"], name: "index_form_entities_on_deleted_at"
    t.index ["field_key"], name: "index_form_entities_on_field_key"
    t.index ["form_id"], name: "index_form_entities_on_form_id"
    t.index ["form_section_id"], name: "index_form_entities_on_form_section_id"
    t.index ["updated_at"], name: "index_form_entities_on_updated_at"
    t.index ["uuid"], name: "index_form_entities_on_uuid"
  end

  create_table "form_entity_choices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "uuid", limit: 36, null: false
    t.integer "company_id", null: false
    t.string "form_id", limit: 36, null: false
    t.string "form_section_id", limit: 36, null: false
    t.string "form_entity_id", limit: 36, null: false
    t.integer "created_by_user_id"
    t.string "value", null: false
    t.integer "position", null: false
    t.boolean "active", default: true
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_form_entity_choices_on_active"
    t.index ["company_id"], name: "index_form_entity_choices_on_company_id"
    t.index ["created_by_user_id"], name: "index_form_entity_choices_on_created_by_user_id"
    t.index ["deleted_at"], name: "index_form_entity_choices_on_deleted_at"
    t.index ["form_entity_id"], name: "index_form_entity_choices_on_form_entity_id"
    t.index ["form_id"], name: "index_form_entity_choices_on_form_id"
    t.index ["form_section_id"], name: "index_form_entity_choices_on_form_section_id"
    t.index ["uuid"], name: "index_form_entity_choices_on_uuid"
  end

  create_table "form_sections", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "uuid", limit: 36, null: false
    t.string "name", null: false
    t.string "form_id", limit: 36, null: false
    t.integer "company_id", null: false
    t.boolean "active", default: true
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "section_type"
    t.index ["active"], name: "index_form_sections_on_active"
    t.index ["company_id"], name: "index_form_sections_on_company_id"
    t.index ["deleted_at"], name: "index_form_sections_on_deleted_at"
    t.index ["form_id"], name: "index_form_sections_on_form_id"
    t.index ["name"], name: "index_form_sections_on_name"
    t.index ["uuid"], name: "index_form_sections_on_uuid"
  end

  create_table "forms", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "uuid", limit: 36, null: false
    t.string "klass_name", null: false
    t.string "model", null: false
    t.integer "company_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_forms_on_company_id"
    t.index ["created_at"], name: "index_forms_on_created_at"
    t.index ["deleted_at"], name: "index_forms_on_deleted_at"
    t.index ["klass_name"], name: "index_forms_on_klass_name"
    t.index ["model"], name: "index_forms_on_model"
    t.index ["updated_at"], name: "index_forms_on_updated_at"
    t.index ["uuid"], name: "index_forms_on_uuid"
  end

  create_table "gatekeeper_blocks", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "user_id"
    t.integer "company_id"
    t.text "params", limit: 16777215
    t.text "headers"
    t.string "act"
    t.string "premise"
    t.string "verdict"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "rule"
    t.integer "level", default: 1, null: false
    t.integer "admin_user_id"
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_gatekeeper_blocks_on_company_id"
    t.index ["user_id"], name: "index_gatekeeper_blocks_on_user_id"
  end

  create_table "general_invoices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "vendor_id"
    t.integer "department_id"
    t.integer "location_id"
    t.integer "cost_center_id"
    t.integer "payment_term_id"
    t.boolean "auto_pay"
    t.text "note"
    t.integer "billing_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "address_id"
    t.date "date"
    t.date "due_date"
    t.text "invoice_number"
    t.integer "tax_type_id"
    t.decimal "discount", precision: 64, scale: 12
    t.integer "discount_type_id"
    t.integer "gross_amount_id"
    t.integer "net_amount_id"
    t.boolean "inclusive_of_taxes"
    t.integer "amount_id"
    t.decimal "tds", precision: 64, scale: 12
    t.integer "tds_type_id"
    t.integer "gst_type_id"
    t.integer "payment_id"
    t.integer "discount_amount_id"
    t.integer "tds_amount_id"
    t.integer "tax_amount_id"
    t.decimal "tax", precision: 64, scale: 12
    t.integer "category_id"
    t.integer "original_amount_id"
    t.integer "advance_amount_id"
    t.integer "advance_type_id"
    t.decimal "advance", precision: 20, scale: 10
    t.integer "freight_amount_id"
    t.integer "freight_type_id"
    t.decimal "freight", precision: 20, scale: 10
    t.decimal "roundoff_amount", precision: 20, scale: 10
    t.integer "balance_due_id"
    t.integer "taxable_amount_id"
    t.integer "tds_slab_id"
    t.integer "invoice_status_id"
    t.integer "company_id"
    t.integer "created_by_user_id"
    t.integer "paid_amount_id"
    t.integer "receiving_account_id"
    t.string "receiving_account_type"
    t.integer "procurement_id"
    t.integer "remaining_amount_id"
    t.integer "invoice_type_id"
    t.integer "sub_department_id"
    t.boolean "is_template", default: false
    t.string "template_name"
    t.boolean "is_deleted", default: false
    t.integer "resource_template_id"
    t.string "invoice_id"
    t.datetime "deleted_at"
    t.integer "gstin_location_id"
    t.date "transaction_service_period_from"
    t.date "transaction_service_period_to"
    t.boolean "cost_allocation_items", default: false
    t.text "narration"
    t.string "po_number"
    t.integer "payment_agreement_id"
    t.integer "bank_account_id"
    t.integer "vendor_location_id"
    t.text "rejection_note"
    t.integer "invoice_frequency_id"
    t.datetime "billing_start_date"
    t.integer "billing_day_of_month"
    t.date "payment_agreement_upcoming_date"
    t.boolean "is_payment_agreement_upcoming_invoice"
    t.integer "recurring_invoice_id"
    t.integer "vendor_poc_id"
    t.integer "vlpm_id"
    t.text "client_note"
    t.date "start_date"
    t.date "end_date"
    t.integer "lock_in_period"
    t.integer "rent_free_period"
    t.integer "tenancy_period"
    t.integer "po_adjusted_advance"
    t.integer "po_advance"
    t.integer "po_prev_adjusted_advance"
    t.boolean "advance_amount_required"
    t.integer "proforma_invoice_id"
    t.integer "proforma_advance"
    t.integer "total_proforma_advance"
    t.integer "delivery_location_id"
    t.integer "template_invoice_id"
    t.boolean "prepaid"
    t.boolean "fixed_periodic_template"
    t.float "escalation_percentage"
    t.string "override_invoice_id"
    t.integer "total_invoice_amount_id"
    t.integer "available_invoice_amount_id"
    t.boolean "include_tax_and_tds", default: false
    t.boolean "rcm_enabled"
    t.index ["template_invoice_id"], name: "index_general_invoices_on_template_invoice_id"
  end

  create_table "google_maps_configs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "device", null: false
    t.string "api_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["device"], name: "index_google_maps_configs_on_device"
  end

  create_table "gst_state_codes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state_code"
    t.datetime "deleted_at"
  end

  create_table "gst_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_gst_types_on_name"
  end

  create_table "gstin_locations", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "vendor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "gstin_id"
    t.string "gstin"
    t.integer "state_id"
    t.string "poc_name"
    t.string "poc_mobile_number"
    t.string "poc_email"
    t.string "poc_fax"
    t.string "poc_designation"
    t.string "location"
    t.text "address"
    t.datetime "deleted_at"
    t.index ["gstin_id"], name: "index_gstin_locations_on_gstin_id"
    t.index ["state_id"], name: "index_gstin_locations_on_state_id"
    t.index ["vendor_id"], name: "index_gstin_locations_on_vendor_id"
  end

  create_table "gstins", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "gstin"
    t.string "legal_name_of_business"
    t.string "state"
    t.date "date_of_registration"
    t.string "constitution_of_business"
    t.string "taxpayer_type"
    t.string "status"
    t.text "api_response", limit: 16777215
    t.string "api_provider"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "address"
    t.string "trade_name"
    t.datetime "deleted_at"
    t.index ["gstin"], name: "index_gstins_on_gstin"
    t.index ["status"], name: "index_gstins_on_status"
  end

  create_table "icici_bank_company_accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.integer "balance_id"
    t.boolean "enabled", default: false
    t.datetime "deleted_at"
  end

  create_table "icici_bank_configs", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "alias_id"
    t.string "urn"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.datetime "deleted_at"
  end

  create_table "icici_bank_transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "aggr_id"
    t.string "aggr_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "corp_id"
    t.string "user_id"
    t.string "debit_acc"
    t.string "credit_acc"
    t.string "txn_type"
    t.integer "amount_id"
    t.string "ifsc"
    t.integer "receiving_account_id"
    t.string "otp"
    t.text "payee_name"
    t.text "remarks"
    t.boolean "customer_induced"
    t.string "transfer_type"
    t.string "unique_request_number"
    t.string "utr"
    t.integer "transfer_status_id"
    t.integer "company_id"
    t.string "request_id"
    t.integer "transfer_mode_id"
    t.datetime "deleted_at"
    t.index ["transfer_mode_id"], name: "index_icici_bank_transactions_on_transfer_mode_id"
  end

  create_table "icici_statements", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "cheque_no"
    t.datetime "txn_date"
    t.decimal "amount", precision: 20, scale: 10
    t.decimal "balance", precision: 20, scale: 10
    t.datetime "value_date"
    t.string "transaction_type"
    t.string "transaction_id"
    t.string "request_id"
    t.integer "bank_transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.text "remarks"
    t.datetime "deleted_at"
  end

  create_table "icici_transaction_callbacks", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "AGGRNAME"
    t.string "AGGRID"
    t.string "URN"
    t.string "UNIQUEID"
    t.string "REQUESTID"
    t.string "TXNSTATUS"
    t.string "UTRNUMBER"
    t.string "CORPID"
    t.string "USERID"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "reconciled", default: false
    t.datetime "deleted_at"
  end

  create_table "individual_kyc_track_actions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_individual_kyc_track_actions_on_name"
  end

  create_table "individual_kyc_tracks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "individual_kyc_id", null: false
    t.integer "action_resource_id"
    t.string "action_resource_type"
    t.integer "action_id", null: false
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["action_id"], name: "index_individual_kyc_tracks_on_action_id"
    t.index ["action_resource_id"], name: "index_individual_kyc_tracks_on_action_resource_id"
    t.index ["action_resource_type"], name: "index_individual_kyc_tracks_on_action_resource_type"
    t.index ["individual_kyc_id"], name: "index_individual_kyc_tracks_on_individual_kyc_id"
  end

  create_table "individual_kyc_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "individual_kycs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "id_proof_file_name"
    t.string "id_proof_content_type"
    t.integer "id_proof_file_size"
    t.datetime "id_proof_updated_at"
    t.integer "kyc_status_id"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address_proof_file_name"
    t.string "address_proof_content_type"
    t.integer "address_proof_file_size"
    t.datetime "address_proof_updated_at"
    t.integer "review_position"
    t.integer "admin_review_workflow_id", null: false
    t.integer "upgraded_by_resource_id"
    t.string "proof_file_1_file_name"
    t.string "proof_file_1_content_type"
    t.integer "proof_file_1_file_size"
    t.datetime "proof_file_1_updated_at"
    t.string "proof_file_1"
    t.string "proof_file_2_file_name"
    t.string "proof_file_2_content_type"
    t.integer "proof_file_2_file_size"
    t.datetime "proof_file_2_updated_at"
    t.string "proof_file_2"
    t.integer "type_id"
    t.string "kyc_file_1_file_name"
    t.string "kyc_file_1_content_type"
    t.integer "kyc_file_1_file_size"
    t.datetime "kyc_file_1_updated_at"
    t.string "kyc_file_2_file_name"
    t.string "kyc_file_2_content_type"
    t.integer "kyc_file_2_file_size"
    t.datetime "kyc_file_2_updated_at"
    t.string "kyc_number"
    t.integer "company_id", null: false
    t.text "admin_note"
    t.datetime "submitted_on"
    t.datetime "upgraded_on"
    t.string "aadhar_front_file_name"
    t.string "aadhar_front_content_type"
    t.integer "aadhar_front_file_size"
    t.datetime "aadhar_front_updated_at"
    t.string "aadhar_back_file_name"
    t.string "aadhar_back_content_type"
    t.integer "aadhar_back_file_size"
    t.datetime "aadhar_back_updated_at"
    t.string "photo_file_name"
    t.string "photo_content_type"
    t.integer "photo_file_size"
    t.datetime "photo_updated_at"
    t.string "signature_file_name"
    t.string "signature_content_type"
    t.integer "signature_file_size"
    t.datetime "signature_updated_at"
    t.string "combined_kyc_file_name"
    t.string "combined_kyc_content_type"
    t.integer "combined_kyc_file_size"
    t.datetime "combined_kyc_updated_at"
    t.string "kyc_1_front_file_name"
    t.string "kyc_1_front_content_type"
    t.integer "kyc_1_front_file_size"
    t.datetime "kyc_1_front_updated_at"
    t.string "kyc_1_back_file_name"
    t.string "kyc_1_back_content_type"
    t.integer "kyc_1_back_file_size"
    t.datetime "kyc_1_back_updated_at"
    t.string "kyc_2_front_file_name"
    t.string "kyc_2_front_content_type"
    t.integer "kyc_2_front_file_size"
    t.datetime "kyc_2_front_updated_at"
    t.string "kyc_2_back_file_name"
    t.string "kyc_2_back_content_type"
    t.integer "kyc_2_back_file_size"
    t.datetime "kyc_2_back_updated_at"
    t.string "kyc_1_number"
    t.string "kyc_2_number"
    t.datetime "deleted_at"
    t.index ["admin_review_workflow_id"], name: "index_individual_kycs_on_admin_review_workflow_id"
    t.index ["company_id"], name: "index_individual_kycs_on_company_id"
    t.index ["kyc_status_id"], name: "index_individual_kycs_on_kyc_status_id"
    t.index ["type_id"], name: "index_individual_kycs_on_type_id"
    t.index ["upgraded_by_resource_id"], name: "index_individual_kycs_on_upgraded_by_resource_id"
    t.index ["user_id"], name: "index_individual_kycs_on_user_id"
  end

  create_table "insight_dashboards", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "uuid", limit: 36, null: false
    t.integer "company_id"
    t.integer "user_id"
    t.integer "policy_id"
    t.integer "user_role_id"
    t.string "application", null: false
    t.integer "dashboard", null: false
    t.string "name"
    t.text "description"
    t.string "app"
    t.integer "admin_user_id"
    t.integer "priority", default: 1
    t.datetime "deleted_at"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "can_filter_from"
    t.boolean "can_filter_to"
    t.index ["active"], name: "index_insight_dashboards_on_active"
    t.index ["admin_user_id"], name: "index_insight_dashboards_on_admin_user_id"
    t.index ["app"], name: "index_insight_dashboards_on_app"
    t.index ["application"], name: "index_insight_dashboards_on_application"
    t.index ["company_id"], name: "index_insight_dashboards_on_company_id"
    t.index ["created_at"], name: "index_insight_dashboards_on_created_at"
    t.index ["dashboard"], name: "index_insight_dashboards_on_dashboard"
    t.index ["deleted_at"], name: "index_insight_dashboards_on_deleted_at"
    t.index ["name"], name: "index_insight_dashboards_on_name"
    t.index ["policy_id"], name: "index_insight_dashboards_on_policy_id"
    t.index ["priority"], name: "index_insight_dashboards_on_priority"
    t.index ["updated_at"], name: "index_insight_dashboards_on_updated_at"
    t.index ["user_id"], name: "index_insight_dashboards_on_user_id"
    t.index ["user_role_id"], name: "index_insight_dashboards_on_user_role_id"
    t.index ["uuid"], name: "index_insight_dashboards_on_uuid"
  end

  create_table "invites", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "vendor_id", null: false
    t.string "token"
    t.string "email", default: "", null: false
    t.datetime "expires_at", default: "2019-08-14 00:00:00", null: false
    t.datetime "accepted_at"
    t.boolean "accepted", default: false
    t.integer "company_id", null: false
    t.integer "gstin_location_id", null: false
    t.integer "vendor_poc_id"
    t.integer "vlpm_id"
    t.boolean "expired", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accepted"], name: "index_invites_on_accepted"
    t.index ["company_id"], name: "index_invites_on_company_id"
    t.index ["email"], name: "index_invites_on_email"
    t.index ["expired"], name: "index_invites_on_expired"
    t.index ["gstin_location_id"], name: "index_invites_on_gstin_location_id"
    t.index ["token"], name: "index_invites_on_token", unique: true
    t.index ["user_id"], name: "index_invites_on_user_id"
    t.index ["vendor_id"], name: "index_invites_on_vendor_id"
  end

  create_table "invoice_attachments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "attached_file_file_name"
    t.string "attached_file_content_type"
    t.integer "attached_file_file_size"
    t.datetime "attached_file_updated_at"
    t.integer "invoice_id"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_invoice_attachments_on_company_id"
    t.index ["invoice_id"], name: "index_invoice_attachments_on_invoice_id"
  end

  create_table "invoice_frequencies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "number"
    t.integer "period_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["period_id"], name: "index_invoice_frequencies_on_period_id"
  end

  create_table "invoice_line_items", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "invoice_id"
    t.text "description"
    t.decimal "quantity", precision: 20, scale: 5
    t.decimal "rate", precision: 20, scale: 10
    t.decimal "tax", precision: 20, scale: 10
    t.decimal "discount", precision: 20, scale: 10
    t.integer "category_id"
    t.integer "gst_type_id"
    t.integer "tax_amount_id"
    t.integer "discount_amount_id"
    t.integer "amount_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "net_amount_id"
    t.string "hsn_sac"
    t.integer "taxable_amount_id"
    t.string "parent_type"
    t.string "parent_id"
    t.integer "inventory_line_item_id"
    t.text "item_info"
    t.text "comment"
    t.string "account"
    t.integer "tax_rate_id"
    t.integer "cost_center_id"
    t.string "unit_of_measurement"
    t.integer "department_id"
    t.decimal "sgst", precision: 20, scale: 5, default: "0.0"
    t.decimal "cgst", precision: 20, scale: 5, default: "0.0"
    t.decimal "igst", precision: 20, scale: 5, default: "0.0"
    t.integer "purchase_order_item_id"
    t.integer "billable_amount_id"
    t.datetime "deleted_at"
    t.index ["amount_id"], name: "index_invoice_line_items_on_amount_id"
    t.index ["category_id"], name: "index_invoice_line_items_on_category_id"
    t.index ["cost_center_id"], name: "index_invoice_line_items_on_cost_center_id"
    t.index ["department_id"], name: "index_invoice_line_items_on_department_id"
    t.index ["discount_amount_id"], name: "index_invoice_line_items_on_discount_amount_id"
    t.index ["gst_type_id"], name: "index_invoice_line_items_on_gst_type_id"
    t.index ["inventory_line_item_id"], name: "index_invoice_line_items_on_inventory_line_item_id"
    t.index ["invoice_id"], name: "index_invoice_line_items_on_invoice_id"
    t.index ["net_amount_id"], name: "index_invoice_line_items_on_net_amount_id"
    t.index ["parent_id", "parent_type"], name: "index_invoice_line_items_on_parent_id_and_parent_type"
    t.index ["purchase_order_item_id"], name: "index_invoice_line_items_on_purchase_order_item_id"
    t.index ["tax_amount_id"], name: "index_invoice_line_items_on_tax_amount_id"
    t.index ["tax_rate_id"], name: "index_invoice_line_items_on_tax_rate_id"
    t.index ["taxable_amount_id"], name: "index_invoice_line_items_on_taxable_amount_id"
  end

  create_table "invoice_number_config_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invoice_number_configs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "prefix", default: ""
    t.string "sequence_start"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "invoice_number_config_type_id"
    t.integer "purpose_id"
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_invoice_number_configs_on_company_id"
    t.index ["invoice_number_config_type_id"], name: "index_invoice_number_configs_on_invoice_number_config_type_id"
    t.index ["purpose_id"], name: "index_invoice_number_configs_on_purpose_id"
  end

  create_table "invoice_reminders", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "days"
    t.string "reference_date_type"
    t.string "timeframe_type"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_invoice_reminders_on_company_id"
  end

  create_table "invoice_transaction_mappings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "invoice_id"
    t.integer "va_transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["invoice_id"], name: "index_invoice_transaction_mappings_on_invoice_id"
    t.index ["va_transaction_id"], name: "index_invoice_transaction_mappings_on_va_transaction_id"
  end

  create_table "invoices", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "address_id"
    t.date "date"
    t.date "due_date"
    t.text "invoice_number"
    t.integer "tax_type_id"
    t.decimal "discount", precision: 64, scale: 12
    t.integer "discount_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "gross_amount_id"
    t.integer "net_amount_id"
    t.boolean "inclusive_of_taxes"
    t.integer "amount_id"
    t.decimal "tds", precision: 64, scale: 12
    t.integer "tds_type_id"
    t.integer "gst_type_id"
    t.integer "payment_id"
    t.integer "discount_amount_id"
    t.integer "tds_amount_id"
    t.integer "tax_amount_id"
    t.decimal "tax", precision: 64, scale: 12
    t.integer "category_id"
    t.integer "original_amount_id"
    t.integer "advance_amount_id"
    t.integer "advance_type_id"
    t.decimal "advance", precision: 20, scale: 10
    t.integer "freight_amount_id"
    t.integer "freight_type_id"
    t.decimal "freight", precision: 20, scale: 10
    t.decimal "roundoff_amount", precision: 20, scale: 10
    t.integer "balance_due_id"
    t.integer "taxable_amount_id"
    t.integer "cost_center_id"
    t.integer "tds_slab_id"
    t.integer "invoice_status_id"
    t.integer "company_id"
    t.integer "created_by_user_id"
    t.integer "paid_amount_id"
    t.integer "vendor_id"
    t.integer "receiving_account_id"
    t.string "receiving_account_type"
    t.text "note"
    t.integer "procurement_id"
    t.integer "remaining_amount_id"
    t.integer "invoice_type_id"
    t.integer "location_id"
    t.integer "delivery_location_id"
    t.integer "payment_term_id"
    t.integer "department_id"
    t.integer "sub_department_id"
    t.integer "policy_id"
    t.integer "controlling_level_id"
    t.integer "controlling_user_id"
    t.integer "controlling_user_role_id"
    t.integer "controlling_for_user_id"
    t.integer "controlling_for_user_role_id"
    t.text "billing_address"
    t.text "shipping_address"
    t.boolean "is_template", default: false
    t.string "template_name"
    t.boolean "is_deleted", default: false
    t.integer "resource_template_id"
    t.string "invoice_id"
    t.datetime "deleted_at"
    t.datetime "submitted_at"
    t.datetime "approved_at"
    t.integer "po_adjusted_advance"
    t.decimal "po_advance", precision: 20, scale: 2
    t.decimal "po_prev_adjusted_advance", precision: 20, scale: 2
    t.boolean "advance_amount_required", default: false
    t.bigint "gstin_location_id"
    t.date "transaction_service_period_from"
    t.date "transaction_service_period_to"
    t.integer "proforma_invoice_id"
    t.integer "proforma_advance"
    t.decimal "total_proforma_advance", precision: 20, scale: 2
    t.boolean "cost_allocation_items", default: false
    t.text "narration"
    t.string "po_number"
    t.integer "bank_account_id"
    t.text "rejection_note"
    t.integer "payment_agreement_id"
    t.integer "vendor_location_id"
    t.integer "billing_type_id"
    t.integer "vendor_poc_id"
    t.integer "vlpm_id"
    t.text "client_note"
    t.string "agreement_item_type"
    t.integer "agreement_item_id"
    t.boolean "payable", default: false
    t.boolean "rcm_enabled", default: false
    t.integer "cn_adjusted_amount_id"
    t.index ["address_id"], name: "index_invoices_on_address_id"
    t.index ["advance_amount_id"], name: "index_invoices_on_advance_amount_id"
    t.index ["amount_id"], name: "index_invoices_on_amount_id"
    t.index ["balance_due_id"], name: "index_invoices_on_balance_due_id"
    t.index ["category_id"], name: "index_invoices_on_category_id"
    t.index ["company_id"], name: "index_invoices_on_company_id"
    t.index ["controlling_for_user_id"], name: "index_invoices_on_controlling_for_user_id"
    t.index ["controlling_for_user_role_id"], name: "index_invoices_on_controlling_for_user_role_id"
    t.index ["controlling_level_id"], name: "index_invoices_on_controlling_level_id"
    t.index ["controlling_user_id"], name: "index_invoices_on_controlling_user_id"
    t.index ["controlling_user_role_id"], name: "index_invoices_on_controlling_user_role_id"
    t.index ["cost_center_id"], name: "index_invoices_on_cost_center_id"
    t.index ["created_by_user_id"], name: "index_invoices_on_created_by_user_id"
    t.index ["deleted_at"], name: "index_invoices_on_deleted_at"
    t.index ["delivery_location_id"], name: "index_invoices_on_delivery_location_id"
    t.index ["department_id"], name: "index_invoices_on_department_id"
    t.index ["discount_amount_id"], name: "index_invoices_on_discount_amount_id"
    t.index ["discount_type_id"], name: "index_invoices_on_discount_type_id"
    t.index ["freight_amount_id"], name: "index_invoices_on_freight_amount_id"
    t.index ["gross_amount_id"], name: "index_invoices_on_gross_amount_id"
    t.index ["gst_type_id"], name: "index_invoices_on_gst_type_id"
    t.index ["gstin_location_id"], name: "index_invoices_on_gstin_location_id"
    t.index ["invoice_status_id"], name: "index_invoices_on_invoice_status_id"
    t.index ["invoice_type_id"], name: "index_invoices_on_invoice_type_id"
    t.index ["location_id"], name: "index_invoices_on_location_id"
    t.index ["net_amount_id"], name: "index_invoices_on_net_amount_id"
    t.index ["original_amount_id"], name: "index_invoices_on_original_amount_id"
    t.index ["payable"], name: "index_invoices_on_payable"
    t.index ["payment_term_id"], name: "index_invoices_on_payment_term_id"
    t.index ["po_adjusted_advance"], name: "index_invoices_on_po_adjusted_advance"
    t.index ["po_number"], name: "index_invoices_on_po_number"
    t.index ["policy_id"], name: "index_invoices_on_policy_id"
    t.index ["procurement_id"], name: "index_invoices_on_procurement_id"
    t.index ["proforma_advance"], name: "index_invoices_on_proforma_advance"
    t.index ["proforma_invoice_id"], name: "index_invoices_on_proforma_invoice_id"
    t.index ["receiving_account_id", "receiving_account_type"], name: "index_invoices_on_receiving_account"
    t.index ["remaining_amount_id"], name: "index_invoices_on_remaining_amount_id"
    t.index ["resource_template_id"], name: "index_invoices_on_resource_template_id"
    t.index ["sub_department_id"], name: "index_invoices_on_sub_department_id"
    t.index ["tax_amount_id"], name: "index_invoices_on_tax_amount_id"
    t.index ["tax_type_id"], name: "index_invoices_on_tax_type_id"
    t.index ["taxable_amount_id"], name: "index_invoices_on_taxable_amount_id"
    t.index ["tds_amount_id"], name: "index_invoices_on_tds_amount_id"
    t.index ["tds_slab_id"], name: "index_invoices_on_tds_slab_id"
    t.index ["transaction_service_period_from"], name: "index_invoices_on_transaction_service_period_from"
    t.index ["transaction_service_period_to"], name: "index_invoices_on_transaction_service_period_to"
    t.index ["vendor_id"], name: "index_invoices_on_vendor_id"
    t.index ["vendor_poc_id"], name: "index_invoices_on_vendor_poc_id"
    t.index ["vlpm_id"], name: "index_invoices_on_vlpm_id"
  end

  create_table "inward_document_items", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "purchase_order_item_id"
    t.integer "inward_document_id"
    t.integer "inventory_line_item_id"
    t.string "product_id"
    t.text "description"
    t.decimal "quantity", precision: 20, scale: 5
    t.decimal "delivered", precision: 20, scale: 5
    t.decimal "accepted", precision: 20, scale: 5
    t.decimal "rejected", precision: 20, scale: 5
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "comment"
    t.decimal "previously_delivered", precision: 20, scale: 5
    t.boolean "is_deleted", default: false, null: false
    t.datetime "deleted_at"
    t.decimal "billable_amount", precision: 20, scale: 5, default: "0.0"
    t.decimal "order_amount", precision: 20, scale: 5, default: "0.0"
    t.decimal "previously_billed_amount", precision: 20, scale: 5, default: "0.0"
    t.integer "product_type_id", default: 1
    t.integer "accepting_item_amount_id"
    t.index ["accepting_item_amount_id"], name: "index_inward_document_items_on_accepting_item_amount_id"
    t.index ["deleted_at"], name: "index_inward_document_items_on_deleted_at"
    t.index ["inventory_line_item_id"], name: "index_inward_document_items_on_inventory_line_item_id"
    t.index ["inward_document_id"], name: "index_inward_document_items_on_inward_document_id"
    t.index ["product_type_id"], name: "index_inward_document_items_on_product_type_id"
    t.index ["purchase_order_item_id", "inventory_line_item_id"], name: "index_inward_item_po_item_item_id"
    t.index ["purchase_order_item_id"], name: "index_inward_document_items_on_purchase_order_item_id"
  end

  create_table "inward_documents", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "company_id"
    t.integer "procurement_id"
    t.integer "vendor_id"
    t.string "doc_number"
    t.string "override_doc_number"
    t.string "prefix"
    t.date "delivery_date"
    t.string "transported_name"
    t.string "transporter_document_number"
    t.string "vehicle_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_deleted", default: false, null: false
    t.integer "user_id"
    t.datetime "deleted_at"
    t.string "grn_number"
    t.index ["company_id"], name: "index_inward_documents_on_company_id"
    t.index ["deleted_at"], name: "index_inward_documents_on_deleted_at"
    t.index ["procurement_id"], name: "index_inward_documents_on_procurement_id"
    t.index ["user_id"], name: "index_inward_documents_on_user_id"
    t.index ["vendor_id"], name: "index_inward_documents_on_vendor_id"
  end

  create_table "inward_invoice_statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "inward_invoice_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "item_expense_types", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "items", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.decimal "tax", precision: 20, scale: 10
    t.decimal "discount", precision: 20, scale: 10
    t.string "hsn_sac"
    t.integer "company_id"
    t.string "sku"
    t.decimal "rate", precision: 20, scale: 10
    t.text "description"
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "note"
    t.integer "tax_rate_id"
    t.boolean "is_deleted", default: false, null: false
    t.string "item_code"
    t.string "account"
    t.integer "supply_item_type_id"
    t.datetime "deleted_at"
    t.integer "product_type_id", default: 1
    t.string "item_number"
    t.string "unit_of_measurement"
    t.integer "user_id"
    t.boolean "active", default: true
    t.integer "item_expense_type_id"
    t.boolean "tds_applicable", default: true
    t.index ["active"], name: "index_items_on_active"
    t.index ["category_id"], name: "index_items_on_category_id"
    t.index ["company_id", "active"], name: "index_items_on_company_id_and_active"
    t.index ["company_id"], name: "index_items_on_company_id"
    t.index ["deleted_at"], name: "index_items_on_deleted_at"
    t.index ["item_expense_type_id"], name: "index_items_on_item_expense_type_id"
    t.index ["product_type_id"], name: "index_items_on_product_type_id"
    t.index ["supply_item_type_id", "product_type_id"], name: "index_items_on_supply_item_type_id_and_product_type_id"
    t.index ["supply_item_type_id"], name: "index_items_on_supply_item_type_id"
    t.index ["tax_rate_id"], name: "index_items_on_tax_rate_id"
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "itz_cash_card_programs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "product_code"
    t.string "charge_code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bank"
    t.datetime "deleted_at"
  end

  create_table "itz_cash_company_accounts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "company_id"
    t.integer "wallet_balance_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "balance_id"
    t.datetime "deleted_at"
    t.index ["balance_id"], name: "index_itz_cash_company_accounts_on_balance_id"
    t.index ["company_id"], name: "index_itz_cash_company_accounts_on_company_id"
    t.index ["wallet_balance_id"], name: "index_itz_cash_company_accounts_on_wallet_balance_id"
  end

  create_table "itz_cash_dmt_beneficiaries", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "middle_name"
    t.string "last_name", null: false
    t.string "mobile_number", null: false
    t.string "relation", null: false
    t.string "ifsc_option", null: false
    t.string "ifsc_code", null: false
    t.string "bank_name"
    t.string "branch_name"
    t.string "bank_city"
    t.string "bank_state"
    t.string "account_number", null: false
    t.string "beneficiary_name", null: false
    t.string "beneficiary_id", null: false
    t.boolean "is_updatable", null: false
    t.integer "itz_cash_dmt_sender_id", null: false
    t.integer "status_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "default"
    t.boolean "reimbursement", default: false
    t.datetime "deleted_at"
    t.index ["itz_cash_dmt_sender_id"], name: "index_itz_cash_dmt_beneficiaries_on_itz_cash_dmt_sender_id"
    t.index ["status_id"], name: "index_itz_cash_dmt_beneficiaries_on_status_id"
  end

  create_table "itz_cash_dmt_beneficiary_statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "itz_cash_dmt_sender_statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "itz_cash_dmt_senders", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "mobile_number", null: false
    t.string "registration_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status_id", null: false
    t.boolean "otp_verified", default: false, null: false
    t.datetime "deleted_at"
    t.index ["status_id"], name: "index_itz_cash_dmt_senders_on_status_id"
    t.index ["user_id"], name: "index_itz_cash_dmt_senders_on_user_id"
  end

  create_table "itz_cash_properties", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "d_code"
    t.string "easy_account_no"
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["company_id"], name: "index_itz_cash_properties_on_company_id"
  end

  create_table "kotak_bank_company_accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.integer "balance_id"
    t.boolean "enabled", default: false
    t.datetime "deleted_at"
  end

  create_table "kotak_bank_configs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "kotak_bank_transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "amount_id"
    t.integer "company_id"
    t.integer "transfer_status_id"
    t.integer "beneficiary_account_id"
    t.string "utr"
    t.string "response_status_code"
    t.string "unique_reference_number"
    t.string "transfer_type"
    t.string "beneficiary_account_number"
    t.string "beneficiary_account_ifsc"
    t.string "beneficiary_name"
    t.string "narration"
    t.date "payment_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "bank_response"
    t.string "reversal_status_code"
    t.text "reversal_response"
    t.integer "reversal_api_counter", default: 0
    t.datetime "deleted_at"
    t.index ["amount_id"], name: "index_kotak_bank_transactions_on_amount_id"
    t.index ["beneficiary_account_id"], name: "index_kotak_bank_transactions_on_beneficiary_account_id"
    t.index ["company_id"], name: "index_kotak_bank_transactions_on_company_id"
    t.index ["response_status_code"], name: "index_kotak_bank_transactions_on_response_status_code"
    t.index ["transfer_status_id"], name: "index_kotak_bank_transactions_on_transfer_status_id"
    t.index ["unique_reference_number"], name: "index_kotak_bank_transactions_on_unique_reference_number"
  end

  create_table "kyc_documents", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "company_kyc_document_type_id"
    t.integer "company_kyc_id"
    t.string "doc_file_name"
    t.string "doc_content_type"
    t.integer "doc_file_size"
    t.datetime "doc_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "identifier"
    t.datetime "deleted_at"
    t.index ["company_kyc_document_type_id"], name: "index_kyc_documents_on_company_kyc_document_type_id"
    t.index ["company_kyc_id"], name: "index_kyc_documents_on_company_kyc_id"
  end

  create_table "kyc_statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "level_reviewer_mappings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "level_id"
    t.integer "reviewer_id"
    t.decimal "threshold", precision: 20, scale: 5, default: "0.0"
    t.boolean "exception", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_deleted", default: false, null: false
    t.datetime "deleted_at"
    t.boolean "wo_exception", default: true
    t.decimal "min", precision: 20, scale: 5, default: "0.0"
    t.decimal "max", precision: 20, scale: 5
    t.index ["deleted_at"], name: "index_level_reviewer_mappings_on_deleted_at"
    t.index ["level_id"], name: "index_level_reviewer_mappings_on_level_id"
    t.index ["reviewer_id"], name: "index_level_reviewer_mappings_on_reviewer_id"
  end

  create_table "level_user_reviewer_mappings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "level_id"
    t.integer "user_id"
    t.integer "reviewer_id"
    t.integer "policy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "threshold", precision: 20, scale: 5, default: "0.0"
    t.boolean "exception", default: true
    t.boolean "wo_exception", default: true
    t.decimal "min", precision: 20, scale: 5, default: "0.0"
    t.decimal "max", precision: 20, scale: 5
    t.datetime "deleted_at"
    t.index ["level_id"], name: "index_level_user_reviewer_mappings_on_level_id"
    t.index ["policy_id"], name: "index_level_user_reviewer_mappings_on_policy_id"
    t.index ["reviewer_id"], name: "index_level_user_reviewer_mappings_on_reviewer_id"
    t.index ["user_id"], name: "index_level_user_reviewer_mappings_on_user_id"
  end

  create_table "locations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "locatable_id"
    t.string "locatable_type"
    t.decimal "latitude", precision: 30, scale: 15
    t.decimal "longitude", precision: 30, scale: 15
    t.string "name", collation: "utf8_bin"
    t.text "address", limit: 16777215, collation: "utf8_bin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order"
    t.string "maps_id"
    t.boolean "is_deleted", default: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_locations_on_deleted_at"
    t.index ["locatable_id"], name: "index_locations_on_locatable_id"
    t.index ["locatable_type"], name: "index_locations_on_locatable_type"
  end

  create_table "login_agreement_mappings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "agreement_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["agreement_id"], name: "index_login_agreement_mappings_on_agreement_id"
    t.index ["user_id"], name: "index_login_agreement_mappings_on_user_id"
  end

  create_table "manager_summary_mail_configs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "period_id", null: false
    t.integer "scheduled_day_of_month"
    t.string "scheduled_day_of_week"
    t.string "scheduled_time", null: false
    t.string "entity_type", null: false
    t.string "application", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["application"], name: "index_manager_summary_mail_configs_on_application"
    t.index ["entity_type"], name: "index_manager_summary_mail_configs_on_entity_type"
    t.index ["period_id"], name: "index_manager_summary_mail_configs_on_period_id"
    t.index ["scheduled_day_of_month"], name: "index_manager_summary_mail_configs_on_scheduled_day_of_month"
    t.index ["scheduled_day_of_week"], name: "index_manager_summary_mail_configs_on_scheduled_day_of_week"
    t.index ["scheduled_time"], name: "index_manager_summary_mail_configs_on_scheduled_time"
    t.index ["user_id"], name: "index_manager_summary_mail_configs_on_user_id"
  end

  create_table "manual_expenses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "expense_id"
    t.string "merchant"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_deleted", default: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_manual_expenses_on_deleted_at"
    t.index ["expense_id"], name: "index_manual_expenses_on_expense_id"
  end

  create_table "mcc_category_mappings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "category_id"
    t.string "mcc_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["category_id"], name: "index_mcc_category_mappings_on_category_id"
  end

  create_table "mcc_groups", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "money_request_actions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "money_request_comment_actions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "money_request_comments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "money_request_id", null: false
    t.integer "comment_action_id", null: false
    t.integer "user_id"
    t.integer "expense_id"
    t.integer "payment_id"
    t.string "updated_field"
    t.text "updated_from"
    t.text "updated_to"
    t.integer "rejected_to_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "delegated_action_user_id"
    t.datetime "deleted_at"
    t.index ["comment_action_id"], name: "index_money_request_comments_on_comment_action_id"
    t.index ["delegated_action_user_id"], name: "index_money_request_comments_on_delegated_action_user_id"
    t.index ["expense_id"], name: "index_money_request_comments_on_expense_id"
    t.index ["money_request_id"], name: "index_money_request_comments_on_money_request_id"
    t.index ["payment_id"], name: "index_money_request_comments_on_payment_id"
    t.index ["rejected_to_id"], name: "index_money_request_comments_on_rejected_to_id"
    t.index ["user_id"], name: "index_money_request_comments_on_user_id"
  end

