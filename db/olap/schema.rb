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

ActiveRecord::Schema.define(version: 2020_01_11_135924) do

  create_table "amounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "finly_ref_id", null: false
    t.datetime "finly_ref_created_at"
    t.datetime "finly_ref_updated_at"
    t.decimal "value", precision: 64, scale: 12
    t.string "currency"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_amounts_on_created_at"
    t.index ["currency"], name: "index_amounts_on_currency"
    t.index ["deleted_at"], name: "index_amounts_on_deleted_at"
    t.index ["finly_ref_created_at"], name: "index_amounts_on_finly_ref_created_at"
    t.index ["finly_ref_id"], name: "index_amounts_on_finly_ref_id"
    t.index ["finly_ref_updated_at"], name: "index_amounts_on_finly_ref_updated_at"
    t.index ["is_deleted"], name: "index_amounts_on_is_deleted"
    t.index ["updated_at"], name: "index_amounts_on_updated_at"
    t.index ["value"], name: "index_amounts_on_value"
  end

  create_table "olap_dimensions_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "finly_ref_id", null: false
    t.datetime "finly_ref_created_at"
    t.datetime "finly_ref_updated_at"
    t.integer "company_id"
    t.string "name"
    t.string "gl_code"
    t.boolean "active"
    t.boolean "expense_management"
    t.boolean "vendor_payments"
    t.boolean "outward_invoices"
    t.boolean "inward_invoice_line_items"
    t.string "ancestry"
    t.boolean "outward_invoice_line_items"
    t.string "category_code"
    t.boolean "gst_applicable"
    t.boolean "tds_applicable"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_olap_dimensions_categories_on_active"
    t.index ["ancestry"], name: "index_olap_dimensions_categories_on_ancestry"
    t.index ["category_code"], name: "index_olap_dimensions_categories_on_category_code"
    t.index ["company_id"], name: "index_olap_dimensions_categories_on_company_id"
    t.index ["created_at"], name: "index_olap_dimensions_categories_on_created_at"
    t.index ["expense_management"], name: "index_olap_dimensions_categories_on_expense_management"
    t.index ["finly_ref_created_at"], name: "index_olap_dimensions_categories_on_finly_ref_created_at"
    t.index ["finly_ref_id"], name: "index_olap_dimensions_categories_on_finly_ref_id"
    t.index ["finly_ref_updated_at"], name: "index_olap_dimensions_categories_on_finly_ref_updated_at"
    t.index ["gl_code"], name: "index_olap_dimensions_categories_on_gl_code"
    t.index ["gst_applicable"], name: "index_olap_dimensions_categories_on_gst_applicable"
    t.index ["inward_invoice_line_items"], name: "index_olap_dimensions_categories_on_inward_invoice_line_items"
    t.index ["name"], name: "index_olap_dimensions_categories_on_name"
    t.index ["outward_invoice_line_items"], name: "index_olap_dimensions_categories_on_outward_invoice_line_items"
    t.index ["outward_invoices"], name: "index_olap_dimensions_categories_on_outward_invoices"
    t.index ["tds_applicable"], name: "index_olap_dimensions_categories_on_tds_applicable"
    t.index ["updated_at"], name: "index_olap_dimensions_categories_on_updated_at"
    t.index ["vendor_payments"], name: "index_olap_dimensions_categories_on_vendor_payments"
  end

  create_table "olap_dimensions_companies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "finly_ref_id", null: false
    t.datetime "finly_ref_created_at"
    t.datetime "finly_ref_updated_at"
    t.string "name"
    t.boolean "active"
    t.integer "base_currency_id"
    t.integer "status"
    t.boolean "test_account"
    t.string "subdomain"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_olap_dimensions_companies_on_active"
    t.index ["base_currency_id"], name: "index_olap_dimensions_companies_on_base_currency_id"
    t.index ["created_at"], name: "index_olap_dimensions_companies_on_created_at"
    t.index ["finly_ref_created_at"], name: "index_olap_dimensions_companies_on_finly_ref_created_at"
    t.index ["finly_ref_id"], name: "index_olap_dimensions_companies_on_finly_ref_id"
    t.index ["finly_ref_updated_at"], name: "index_olap_dimensions_companies_on_finly_ref_updated_at"
    t.index ["group_id"], name: "index_olap_dimensions_companies_on_group_id"
    t.index ["name"], name: "index_olap_dimensions_companies_on_name"
    t.index ["status"], name: "index_olap_dimensions_companies_on_status"
    t.index ["subdomain"], name: "index_olap_dimensions_companies_on_subdomain"
    t.index ["test_account"], name: "index_olap_dimensions_companies_on_test_account"
    t.index ["updated_at"], name: "index_olap_dimensions_companies_on_updated_at"
  end

  create_table "olap_dimensions_cost_centers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "finly_ref_id", null: false
    t.datetime "finly_ref_created_at"
    t.datetime "finly_ref_updated_at"
    t.string "name"
    t.string "application"
    t.integer "company_id"
    t.boolean "is_deleted"
    t.datetime "deleted_at"
    t.string "cost_center_code"
    t.string "ancestry"
    t.string "gl_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ancestry"], name: "index_olap_dimensions_cost_centers_on_ancestry"
    t.index ["application"], name: "index_olap_dimensions_cost_centers_on_application"
    t.index ["company_id"], name: "index_olap_dimensions_cost_centers_on_company_id"
    t.index ["cost_center_code"], name: "index_olap_dimensions_cost_centers_on_cost_center_code"
    t.index ["created_at"], name: "index_olap_dimensions_cost_centers_on_created_at"
    t.index ["deleted_at"], name: "index_olap_dimensions_cost_centers_on_deleted_at"
    t.index ["finly_ref_created_at"], name: "index_olap_dimensions_cost_centers_on_finly_ref_created_at"
    t.index ["finly_ref_id"], name: "index_olap_dimensions_cost_centers_on_finly_ref_id"
    t.index ["finly_ref_updated_at"], name: "index_olap_dimensions_cost_centers_on_finly_ref_updated_at"
    t.index ["gl_code"], name: "index_olap_dimensions_cost_centers_on_gl_code"
    t.index ["is_deleted"], name: "index_olap_dimensions_cost_centers_on_is_deleted"
    t.index ["name"], name: "index_olap_dimensions_cost_centers_on_name"
    t.index ["updated_at"], name: "index_olap_dimensions_cost_centers_on_updated_at"
  end

  create_table "olap_dimensions_departments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "finly_ref_id", null: false
    t.datetime "finly_ref_created_at"
    t.datetime "finly_ref_updated_at"
    t.string "name"
    t.integer "company_id"
    t.boolean "is_deleted"
    t.string "ancestry"
    t.integer "cost_center_id"
    t.datetime "deleted_at"
    t.string "department_code"
    t.string "code"
    t.string "gl_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ancestry"], name: "index_olap_dimensions_departments_on_ancestry"
    t.index ["code"], name: "index_olap_dimensions_departments_on_code"
    t.index ["company_id"], name: "index_olap_dimensions_departments_on_company_id"
    t.index ["cost_center_id"], name: "index_olap_dimensions_departments_on_cost_center_id"
    t.index ["created_at"], name: "index_olap_dimensions_departments_on_created_at"
    t.index ["deleted_at"], name: "index_olap_dimensions_departments_on_deleted_at"
    t.index ["department_code"], name: "index_olap_dimensions_departments_on_department_code"
    t.index ["finly_ref_created_at"], name: "index_olap_dimensions_departments_on_finly_ref_created_at"
    t.index ["finly_ref_id"], name: "index_olap_dimensions_departments_on_finly_ref_id"
    t.index ["finly_ref_updated_at"], name: "index_olap_dimensions_departments_on_finly_ref_updated_at"
    t.index ["gl_code"], name: "index_olap_dimensions_departments_on_gl_code"
    t.index ["is_deleted"], name: "index_olap_dimensions_departments_on_is_deleted"
    t.index ["name"], name: "index_olap_dimensions_departments_on_name"
    t.index ["updated_at"], name: "index_olap_dimensions_departments_on_updated_at"
  end

  create_table "olap_dimensions_fiscal_times", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "finly_ref_id", null: false
    t.datetime "finly_ref_created_at"
    t.datetime "finly_ref_updated_at"
    t.datetime "datetime"
    t.date "date"
    t.string "day_of_week"
    t.integer "day_of_month"
    t.integer "week"
    t.integer "month"
    t.string "quarter"
    t.string "half"
    t.integer "year"
    t.integer "fiscal_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_olap_dimensions_fiscal_times_on_created_at"
    t.index ["date"], name: "index_olap_dimensions_fiscal_times_on_date"
    t.index ["datetime"], name: "index_olap_dimensions_fiscal_times_on_datetime"
    t.index ["day_of_month"], name: "index_olap_dimensions_fiscal_times_on_day_of_month"
    t.index ["day_of_week"], name: "index_olap_dimensions_fiscal_times_on_day_of_week"
    t.index ["finly_ref_created_at"], name: "index_olap_dimensions_fiscal_times_on_finly_ref_created_at"
    t.index ["finly_ref_id"], name: "index_olap_dimensions_fiscal_times_on_finly_ref_id"
    t.index ["finly_ref_updated_at"], name: "index_olap_dimensions_fiscal_times_on_finly_ref_updated_at"
    t.index ["fiscal_year"], name: "index_olap_dimensions_fiscal_times_on_fiscal_year"
    t.index ["half"], name: "index_olap_dimensions_fiscal_times_on_half"
    t.index ["month"], name: "index_olap_dimensions_fiscal_times_on_month"
    t.index ["quarter"], name: "index_olap_dimensions_fiscal_times_on_quarter"
    t.index ["updated_at"], name: "index_olap_dimensions_fiscal_times_on_updated_at"
    t.index ["week"], name: "index_olap_dimensions_fiscal_times_on_week"
    t.index ["year"], name: "index_olap_dimensions_fiscal_times_on_year"
  end

  create_table "olap_dimensions_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "finly_ref_id", null: false
    t.datetime "finly_ref_created_at"
    t.datetime "finly_ref_updated_at"
    t.decimal "tax", precision: 10
    t.decimal "discount", precision: 10
    t.string "hsn_sac"
    t.integer "company_id"
    t.string "sku"
    t.decimal "rate", precision: 10
    t.text "description"
    t.integer "category_id"
    t.text "note"
    t.integer "tax_rate_id"
    t.boolean "is_deleted"
    t.string "item_code"
    t.string "account"
    t.integer "supply_item_type_id"
    t.datetime "deleted_at"
    t.integer "product_type_id"
    t.string "item_number"
    t.string "unit_of_measurement"
    t.integer "user_id"
    t.boolean "active"
    t.integer "item_expense_type_id"
    t.boolean "tds_applicable"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account"], name: "index_olap_dimensions_items_on_account"
    t.index ["active"], name: "index_olap_dimensions_items_on_active"
    t.index ["category_id"], name: "index_olap_dimensions_items_on_category_id"
    t.index ["company_id"], name: "index_olap_dimensions_items_on_company_id"
    t.index ["created_at"], name: "index_olap_dimensions_items_on_created_at"
    t.index ["deleted_at"], name: "index_olap_dimensions_items_on_deleted_at"
    t.index ["discount"], name: "index_olap_dimensions_items_on_discount"
    t.index ["finly_ref_created_at"], name: "index_olap_dimensions_items_on_finly_ref_created_at"
    t.index ["finly_ref_id"], name: "index_olap_dimensions_items_on_finly_ref_id"
    t.index ["finly_ref_updated_at"], name: "index_olap_dimensions_items_on_finly_ref_updated_at"
    t.index ["hsn_sac"], name: "index_olap_dimensions_items_on_hsn_sac"
    t.index ["is_deleted"], name: "index_olap_dimensions_items_on_is_deleted"
    t.index ["item_code"], name: "index_olap_dimensions_items_on_item_code"
    t.index ["item_expense_type_id"], name: "index_olap_dimensions_items_on_item_expense_type_id"
    t.index ["item_number"], name: "index_olap_dimensions_items_on_item_number"
    t.index ["product_type_id"], name: "index_olap_dimensions_items_on_product_type_id"
    t.index ["rate"], name: "index_olap_dimensions_items_on_rate"
    t.index ["sku"], name: "index_olap_dimensions_items_on_sku"
    t.index ["supply_item_type_id"], name: "index_olap_dimensions_items_on_supply_item_type_id"
    t.index ["tax"], name: "index_olap_dimensions_items_on_tax"
    t.index ["tax_rate_id"], name: "index_olap_dimensions_items_on_tax_rate_id"
    t.index ["tds_applicable"], name: "index_olap_dimensions_items_on_tds_applicable"
    t.index ["unit_of_measurement"], name: "index_olap_dimensions_items_on_unit_of_measurement"
    t.index ["updated_at"], name: "index_olap_dimensions_items_on_updated_at"
    t.index ["user_id"], name: "index_olap_dimensions_items_on_user_id"
  end

  create_table "olap_dimensions_locations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "finly_ref_id", null: false
    t.datetime "finly_ref_created_at"
    t.datetime "finly_ref_updated_at"
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
    t.string "contact_name"
    t.string "contact_mobile_number"
    t.boolean "is_deleted"
    t.datetime "deleted_at"
    t.string "location_code"
    t.string "ancestry"
    t.string "nature_of_office"
    t.boolean "billable_location"
    t.boolean "shippable_location"
    t.string "gl_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ancestry"], name: "index_olap_dimensions_locations_on_ancestry"
    t.index ["billable_location"], name: "index_olap_dimensions_locations_on_billable_location"
    t.index ["city"], name: "index_olap_dimensions_locations_on_city"
    t.index ["company_id"], name: "index_olap_dimensions_locations_on_company_id"
    t.index ["contact_mobile_number"], name: "index_olap_dimensions_locations_on_contact_mobile_number"
    t.index ["contact_name"], name: "index_olap_dimensions_locations_on_contact_name"
    t.index ["country"], name: "index_olap_dimensions_locations_on_country"
    t.index ["created_at"], name: "index_olap_dimensions_locations_on_created_at"
    t.index ["deleted_at"], name: "index_olap_dimensions_locations_on_deleted_at"
    t.index ["finly_ref_created_at"], name: "index_olap_dimensions_locations_on_finly_ref_created_at"
    t.index ["finly_ref_id"], name: "index_olap_dimensions_locations_on_finly_ref_id"
    t.index ["finly_ref_updated_at"], name: "index_olap_dimensions_locations_on_finly_ref_updated_at"
    t.index ["gl_code"], name: "index_olap_dimensions_locations_on_gl_code"
    t.index ["gstin"], name: "index_olap_dimensions_locations_on_gstin"
    t.index ["is_deleted"], name: "index_olap_dimensions_locations_on_is_deleted"
    t.index ["location_code"], name: "index_olap_dimensions_locations_on_location_code"
    t.index ["name"], name: "index_olap_dimensions_locations_on_name"
    t.index ["nature_of_office"], name: "index_olap_dimensions_locations_on_nature_of_office"
    t.index ["pan"], name: "index_olap_dimensions_locations_on_pan"
    t.index ["pin"], name: "index_olap_dimensions_locations_on_pin"
    t.index ["shippable_location"], name: "index_olap_dimensions_locations_on_shippable_location"
    t.index ["state_id"], name: "index_olap_dimensions_locations_on_state_id"
    t.index ["updated_at"], name: "index_olap_dimensions_locations_on_updated_at"
  end

  create_table "olap_dimensions_policies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "finly_ref_id", null: false
    t.datetime "finly_ref_created_at"
    t.datetime "finly_ref_updated_at"
    t.string "name"
    t.integer "company_id"
    t.integer "owner_id"
    t.boolean "default"
    t.boolean "is_deleted"
    t.text "description"
    t.integer "base_currency_id"
    t.string "application"
    t.integer "settlement_currency_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application"], name: "index_olap_dimensions_policies_on_application"
    t.index ["base_currency_id"], name: "index_olap_dimensions_policies_on_base_currency_id"
    t.index ["company_id"], name: "index_olap_dimensions_policies_on_company_id"
    t.index ["created_at"], name: "index_olap_dimensions_policies_on_created_at"
    t.index ["default"], name: "index_olap_dimensions_policies_on_default"
    t.index ["deleted_at"], name: "index_olap_dimensions_policies_on_deleted_at"
    t.index ["finly_ref_created_at"], name: "index_olap_dimensions_policies_on_finly_ref_created_at"
    t.index ["finly_ref_id"], name: "index_olap_dimensions_policies_on_finly_ref_id"
    t.index ["finly_ref_updated_at"], name: "index_olap_dimensions_policies_on_finly_ref_updated_at"
    t.index ["is_deleted"], name: "index_olap_dimensions_policies_on_is_deleted"
    t.index ["name"], name: "index_olap_dimensions_policies_on_name"
    t.index ["owner_id"], name: "index_olap_dimensions_policies_on_owner_id"
    t.index ["settlement_currency_id"], name: "index_olap_dimensions_policies_on_settlement_currency_id"
    t.index ["updated_at"], name: "index_olap_dimensions_policies_on_updated_at"
  end

  create_table "olap_dimensions_tax_rates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "finly_ref_id", null: false
    t.datetime "finly_ref_created_at"
    t.datetime "finly_ref_updated_at"
    t.string "name"
    t.decimal "rate", precision: 10
    t.string "internal_id"
    t.integer "company_id"
    t.boolean "is_deleted"
    t.datetime "deleted_at"
    t.decimal "cgst", precision: 10
    t.decimal "sgst", precision: 10
    t.decimal "igst", precision: 10
    t.string "igst_internal_id"
    t.string "cgst_internal_id"
    t.string "sgst_internal_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cgst"], name: "index_olap_dimensions_tax_rates_on_cgst"
    t.index ["cgst_internal_id"], name: "index_olap_dimensions_tax_rates_on_cgst_internal_id"
    t.index ["company_id"], name: "index_olap_dimensions_tax_rates_on_company_id"
    t.index ["created_at"], name: "index_olap_dimensions_tax_rates_on_created_at"
    t.index ["deleted_at"], name: "index_olap_dimensions_tax_rates_on_deleted_at"
    t.index ["finly_ref_created_at"], name: "index_olap_dimensions_tax_rates_on_finly_ref_created_at"
    t.index ["finly_ref_id"], name: "index_olap_dimensions_tax_rates_on_finly_ref_id"
    t.index ["finly_ref_updated_at"], name: "index_olap_dimensions_tax_rates_on_finly_ref_updated_at"
    t.index ["igst"], name: "index_olap_dimensions_tax_rates_on_igst"
    t.index ["igst_internal_id"], name: "index_olap_dimensions_tax_rates_on_igst_internal_id"
    t.index ["internal_id"], name: "index_olap_dimensions_tax_rates_on_internal_id"
    t.index ["is_deleted"], name: "index_olap_dimensions_tax_rates_on_is_deleted"
    t.index ["name"], name: "index_olap_dimensions_tax_rates_on_name"
    t.index ["rate"], name: "index_olap_dimensions_tax_rates_on_rate"
    t.index ["sgst"], name: "index_olap_dimensions_tax_rates_on_sgst"
    t.index ["sgst_internal_id"], name: "index_olap_dimensions_tax_rates_on_sgst_internal_id"
    t.index ["updated_at"], name: "index_olap_dimensions_tax_rates_on_updated_at"
  end

  create_table "olap_dimensions_tds_rates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "finly_ref_id", null: false
    t.datetime "finly_ref_created_at"
    t.datetime "finly_ref_updated_at"
    t.string "name"
    t.decimal "tds", precision: 10
    t.integer "company_id"
    t.string "gl_code"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_olap_dimensions_tds_rates_on_company_id"
    t.index ["created_at"], name: "index_olap_dimensions_tds_rates_on_created_at"
    t.index ["deleted_at"], name: "index_olap_dimensions_tds_rates_on_deleted_at"
    t.index ["finly_ref_created_at"], name: "index_olap_dimensions_tds_rates_on_finly_ref_created_at"
    t.index ["finly_ref_id"], name: "index_olap_dimensions_tds_rates_on_finly_ref_id"
    t.index ["finly_ref_updated_at"], name: "index_olap_dimensions_tds_rates_on_finly_ref_updated_at"
    t.index ["gl_code"], name: "index_olap_dimensions_tds_rates_on_gl_code"
    t.index ["name"], name: "index_olap_dimensions_tds_rates_on_name"
    t.index ["tds"], name: "index_olap_dimensions_tds_rates_on_tds"
    t.index ["updated_at"], name: "index_olap_dimensions_tds_rates_on_updated_at"
  end

  create_table "olap_dimensions_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "finly_ref_id", null: false
    t.datetime "finly_ref_created_at"
    t.datetime "finly_ref_updated_at"
    t.string "email"
    t.string "employee_id"
    t.boolean "kyc_verified"
    t.integer "company_id"
    t.string "mobile_number"
    t.boolean "active"
    t.boolean "otp_verified"
    t.string "first_name"
    t.string "last_name"
    t.boolean "mobile_only_invite"
    t.boolean "verified"
    t.boolean "default_password"
    t.boolean "point_of_contact"
    t.datetime "password_changed_at"
    t.datetime "last_activity_at"
    t.datetime "expired_at"
    t.integer "cost_center_id"
    t.integer "department_id"
    t.integer "location_id"
    t.integer "default_company_id"
    t.string "finly_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_olap_dimensions_users_on_active"
    t.index ["company_id"], name: "index_olap_dimensions_users_on_company_id"
    t.index ["cost_center_id"], name: "index_olap_dimensions_users_on_cost_center_id"
    t.index ["created_at"], name: "index_olap_dimensions_users_on_created_at"
    t.index ["default_company_id"], name: "index_olap_dimensions_users_on_default_company_id"
    t.index ["default_password"], name: "index_olap_dimensions_users_on_default_password"
    t.index ["department_id"], name: "index_olap_dimensions_users_on_department_id"
    t.index ["email"], name: "index_olap_dimensions_users_on_email"
    t.index ["employee_id"], name: "index_olap_dimensions_users_on_employee_id"
    t.index ["expired_at"], name: "index_olap_dimensions_users_on_expired_at"
    t.index ["finly_id"], name: "index_olap_dimensions_users_on_finly_id"
    t.index ["finly_ref_created_at"], name: "index_olap_dimensions_users_on_finly_ref_created_at"
    t.index ["finly_ref_id"], name: "index_olap_dimensions_users_on_finly_ref_id"
    t.index ["finly_ref_updated_at"], name: "index_olap_dimensions_users_on_finly_ref_updated_at"
    t.index ["first_name"], name: "index_olap_dimensions_users_on_first_name"
    t.index ["kyc_verified"], name: "index_olap_dimensions_users_on_kyc_verified"
    t.index ["last_activity_at"], name: "index_olap_dimensions_users_on_last_activity_at"
    t.index ["last_name"], name: "index_olap_dimensions_users_on_last_name"
    t.index ["location_id"], name: "index_olap_dimensions_users_on_location_id"
    t.index ["mobile_number"], name: "index_olap_dimensions_users_on_mobile_number"
    t.index ["mobile_only_invite"], name: "index_olap_dimensions_users_on_mobile_only_invite"
    t.index ["otp_verified"], name: "index_olap_dimensions_users_on_otp_verified"
    t.index ["password_changed_at"], name: "index_olap_dimensions_users_on_password_changed_at"
    t.index ["point_of_contact"], name: "index_olap_dimensions_users_on_point_of_contact"
    t.index ["updated_at"], name: "index_olap_dimensions_users_on_updated_at"
    t.index ["verified"], name: "index_olap_dimensions_users_on_verified"
  end

  create_table "olap_facts_spend_transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "finly_ref_id", null: false
    t.datetime "finly_ref_created_at"
    t.datetime "finly_ref_updated_at"
    t.string "document_type"
    t.integer "document_id"
    t.string "parent_document_type"
    t.integer "parent_document_id"
    t.boolean "is_reimbursable"
    t.integer "reimbursed_on_id"
    t.string "status"
    t.string "description"
    t.text "detailed_description"
    t.integer "parent_cost_center_id"
    t.integer "cost_center_id"
    t.integer "parent_location_id"
    t.integer "location_id"
    t.integer "parent_department_id"
    t.integer "department_id"
    t.integer "parent_category_id"
    t.integer "category_id"
    t.integer "policy_id"
    t.integer "owner_id"
    t.integer "service_period_start_id"
    t.integer "service_period_end_id"
    t.integer "date_id"
    t.integer "transaction_created_at_id"
    t.integer "transaction_submitted_at_id"
    t.integer "transaction_approved_at_id"
    t.integer "transaction_rejected_at_id"
    t.integer "transaction_rejection_count"
    t.boolean "has_violation"
    t.string "violation_description"
    t.boolean "is_employee_expense"
    t.boolean "is_vendor_payment"
    t.integer "vendor_id"
    t.integer "vendor_location_id"
    t.string "vendor_name"
    t.integer "shipping_location_id"
    t.integer "billing_location_id"
    t.boolean "is_gst_registered"
    t.boolean "is_msme_registered"
    t.boolean "is_composite_vendor"
    t.integer "vendor_confirmed_at_id"
    t.integer "days_for_confirmation"
    t.string "payment_mode"
    t.decimal "quantity", precision: 10
    t.integer "estimated_delivery_date_id"
    t.integer "delivery_completed_on_id"
    t.boolean "is_delivered_on_time"
    t.boolean "has_on_time_delivery"
    t.boolean "has_late_delivery"
    t.integer "delivery_delayed_days"
    t.decimal "quantity_delivered_on_time", precision: 10
    t.decimal "quantity_delivered_on_time_percentage", precision: 10
    t.decimal "quantity_delivered_late", precision: 10
    t.decimal "quantity_delivered_late_percentage", precision: 10
    t.boolean "is_exceeding_budget"
    t.string "item_type"
    t.integer "item_id"
    t.string "asset_type"
    t.integer "amount_id"
    t.integer "basic_amount_id"
    t.integer "tax_amount_id"
    t.integer "tds_amount_id"
    t.string "tax_type"
    t.decimal "tax_percentage", precision: 10
    t.integer "cgst_amount_id"
    t.integer "sgst_amount_id"
    t.integer "igst_amount_id"
    t.decimal "cgst_percentage", precision: 10
    t.decimal "sgst_percentage", precision: 10
    t.decimal "igst_percentage", precision: 10
    t.integer "advance_amount_requested_id"
    t.integer "advance_amount_paid_id"
    t.decimal "advance_percentage", precision: 10
    t.integer "credit_days"
    t.integer "reimbursement_amount_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["advance_percentage"], name: "index_olap_facts_spend_transactions_on_advance_percentage"
    t.index ["cgst_percentage"], name: "index_olap_facts_spend_transactions_on_cgst_percentage"
    t.index ["created_at"], name: "index_olap_facts_spend_transactions_on_created_at"
    t.index ["credit_days"], name: "index_olap_facts_spend_transactions_on_credit_days"
    t.index ["days_for_confirmation"], name: "index_olap_facts_spend_transactions_on_days_for_confirmation"
    t.index ["delivery_delayed_days"], name: "index_olap_facts_spend_transactions_on_delivery_delayed_days"
    t.index ["description"], name: "index_olap_facts_spend_transactions_on_description"
    t.index ["document_id"], name: "index_olap_facts_spend_transactions_on_document_id"
    t.index ["document_type"], name: "index_olap_facts_spend_transactions_on_document_type"
    t.index ["finly_ref_created_at"], name: "index_olap_facts_spend_transactions_on_finly_ref_created_at"
    t.index ["finly_ref_id"], name: "index_olap_facts_spend_transactions_on_finly_ref_id"
    t.index ["finly_ref_updated_at"], name: "index_olap_facts_spend_transactions_on_finly_ref_updated_at"
    t.index ["has_late_delivery"], name: "index_olap_facts_spend_transactions_on_has_late_delivery"
    t.index ["has_on_time_delivery"], name: "index_olap_facts_spend_transactions_on_has_on_time_delivery"
    t.index ["has_violation"], name: "index_olap_facts_spend_transactions_on_has_violation"
    t.index ["igst_percentage"], name: "index_olap_facts_spend_transactions_on_igst_percentage"
    t.index ["is_composite_vendor"], name: "index_olap_facts_spend_transactions_on_is_composite_vendor"
    t.index ["is_delivered_on_time"], name: "index_olap_facts_spend_transactions_on_is_delivered_on_time"
    t.index ["is_employee_expense"], name: "index_olap_facts_spend_transactions_on_is_employee_expense"
    t.index ["is_exceeding_budget"], name: "index_olap_facts_spend_transactions_on_is_exceeding_budget"
    t.index ["is_gst_registered"], name: "index_olap_facts_spend_transactions_on_is_gst_registered"
    t.index ["is_msme_registered"], name: "index_olap_facts_spend_transactions_on_is_msme_registered"
    t.index ["is_reimbursable"], name: "index_olap_facts_spend_transactions_on_is_reimbursable"
    t.index ["is_vendor_payment"], name: "index_olap_facts_spend_transactions_on_is_vendor_payment"
    t.index ["item_type"], name: "index_olap_facts_spend_transactions_on_item_type"
    t.index ["parent_document_id"], name: "index_olap_facts_spend_transactions_on_parent_document_id"
    t.index ["parent_document_type"], name: "index_olap_facts_spend_transactions_on_parent_document_type"
    t.index ["payment_mode"], name: "index_olap_facts_spend_transactions_on_payment_mode"
    t.index ["quantity"], name: "index_olap_facts_spend_transactions_on_quantity"
    t.index ["quantity_delivered_late"], name: "index_facts_spend_transactions_delivered_late"
    t.index ["quantity_delivered_late_percentage"], name: "index_facts_spend_transactions_delivered_late_percentage"
    t.index ["quantity_delivered_on_time"], name: "index_facts_spend_transactions_delivered_on_time"
    t.index ["quantity_delivered_on_time_percentage"], name: "index_facts_spend_transactions_delivered_on_time_percentage"
    t.index ["sgst_percentage"], name: "index_olap_facts_spend_transactions_on_sgst_percentage"
    t.index ["status"], name: "index_olap_facts_spend_transactions_on_status"
    t.index ["tax_percentage"], name: "index_olap_facts_spend_transactions_on_tax_percentage"
    t.index ["tax_type"], name: "index_olap_facts_spend_transactions_on_tax_type"
    t.index ["transaction_rejected_at_id"], name: "index_facts_spend_transactions_rejected_at"
    t.index ["transaction_rejection_count"], name: "index_facts_spend_transactions_rejection_count"
    t.index ["updated_at"], name: "index_olap_facts_spend_transactions_on_updated_at"
    t.index ["vendor_name"], name: "index_olap_facts_spend_transactions_on_vendor_name"
    t.index ["violation_description"], name: "index_olap_facts_spend_transactions_on_violation_description"
  end

  create_table "olap_facts_spends", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "finly_ref_id", null: false
    t.datetime "finly_ref_created_at"
    t.datetime "finly_ref_updated_at"
    t.boolean "is_reimbursement"
    t.integer "reimbursement_on_id"
    t.string "description"
    t.text "detailed_description"
    t.integer "parent_cost_center_id"
    t.integer "cost_center_id"
    t.integer "parent_location_id"
    t.integer "location_id"
    t.integer "parent_department_id"
    t.integer "department_id"
    t.integer "parent_category_id"
    t.integer "category_id"
    t.integer "policy_id"
    t.integer "owner_id"
    t.integer "service_period_start_id"
    t.integer "service_period_end_id"
    t.integer "date_id"
    t.boolean "is_employee_expense"
    t.boolean "is_vendor_payment"
    t.integer "vendor_id"
    t.integer "vendor_location_id"
    t.string "vendor_name"
    t.integer "shipping_location_id"
    t.integer "billing_location_id"
    t.boolean "is_gst_registered"
    t.boolean "is_msme_registered"
    t.boolean "is_composite_vendor"
    t.integer "vendor_confirmed_at_id"
    t.integer "days_for_confirmation"
    t.integer "payment_mode"
    t.boolean "has_purchase_request"
    t.boolean "has_purchase_order"
    t.boolean "has_grn"
    t.boolean "has_invoice"
    t.boolean "has_agreement"
    t.decimal "quantity_requested", precision: 10
    t.decimal "quantity_issued_from_inventory", precision: 10
    t.decimal "quantity_purchased", precision: 10
    t.decimal "quantity_cancelled", precision: 10
    t.decimal "quantity_received", precision: 10
    t.decimal "quantity_invoiced", precision: 10
    t.decimal "quantity_paid", precision: 10
    t.decimal "quantity_pending_purchase", precision: 10
    t.decimal "quantity_pending_receipt", precision: 10
    t.decimal "quantity_pending_invoice", precision: 10
    t.decimal "quantity_pending_payment", precision: 10
    t.integer "purchased_on_id"
    t.integer "estimated_delivery_date_id"
    t.integer "delivery_completed_on_id"
    t.boolean "is_delivered_on_time"
    t.boolean "has_on_time_delivery"
    t.boolean "has_late_delivery"
    t.integer "delivery_delayed_days"
    t.decimal "quantity_delivered_on_time", precision: 10
    t.decimal "quantity_delivered_on_time_percentage", precision: 10
    t.decimal "quantity_delivered_late", precision: 10
    t.decimal "quantity_delivered_late_percentage", precision: 10
    t.decimal "quantity_purchased_percentage", precision: 10
    t.decimal "quantity_received_percentage", precision: 10
    t.decimal "quantity_invoiced_percentage", precision: 10
    t.decimal "quantity_cancelled_percentage", precision: 10
    t.decimal "quantity_paid_percentage", precision: 10
    t.boolean "is_exceeding_budget"
    t.string "item_type"
    t.integer "item_id"
    t.string "asset_type"
    t.integer "amount_id"
    t.integer "basic_amount_id"
    t.integer "tax_amount_id"
    t.integer "tds_amount_id"
    t.string "tax_type"
    t.decimal "tax_percentage", precision: 10
    t.integer "cgst_amount_id"
    t.integer "sgst_amount_id"
    t.integer "igst_amount_id"
    t.decimal "cgst_percentage", precision: 10
    t.decimal "sgst_percentage", precision: 10
    t.decimal "igst_percentage", precision: 10
    t.integer "amount_estimated_id"
    t.integer "amount_purchased_id"
    t.integer "amount_received_id"
    t.integer "amount_invoiced_id"
    t.integer "amount_paid_id"
    t.integer "amount_pending_purchase_id"
    t.integer "amount_pending_receipt_id"
    t.integer "amount_pending_invoice_id"
    t.integer "amount_pending_payment_id"
    t.integer "advance_amount_requested_id"
    t.integer "advance_amount_paid_id"
    t.decimal "advance_percentage", precision: 10
    t.integer "credit_days"
    t.integer "estimated_deviation_id"
    t.decimal "estimated_deviation_percentage", precision: 10
    t.decimal "reimbursement_amount_id", precision: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.index ["advance_percentage"], name: "index_olap_facts_spends_on_advance_percentage"
    t.index ["asset_type"], name: "index_olap_facts_spends_on_asset_type"
    t.index ["cgst_percentage"], name: "index_olap_facts_spends_on_cgst_percentage"
    t.index ["created_at"], name: "index_olap_facts_spends_on_created_at"
    t.index ["credit_days"], name: "index_olap_facts_spends_on_credit_days"
    t.index ["days_for_confirmation"], name: "index_olap_facts_spends_on_days_for_confirmation"
    t.index ["delivery_delayed_days"], name: "index_olap_facts_spends_on_delivery_delayed_days"
    t.index ["description"], name: "index_olap_facts_spends_on_description"
    t.index ["estimated_deviation_percentage"], name: "olap_facts_spends_est_deviation_percentage"
    t.index ["finly_ref_created_at"], name: "index_olap_facts_spends_on_finly_ref_created_at"
    t.index ["finly_ref_id"], name: "index_olap_facts_spends_on_finly_ref_id"
    t.index ["finly_ref_updated_at"], name: "index_olap_facts_spends_on_finly_ref_updated_at"
    t.index ["has_agreement"], name: "index_olap_facts_spends_on_has_agreement"
    t.index ["has_grn"], name: "index_olap_facts_spends_on_has_grn"
    t.index ["has_invoice"], name: "index_olap_facts_spends_on_has_invoice"
    t.index ["has_late_delivery"], name: "index_olap_facts_spends_on_has_late_delivery"
    t.index ["has_on_time_delivery"], name: "index_olap_facts_spends_on_has_on_time_delivery"
    t.index ["has_purchase_order"], name: "index_olap_facts_spends_on_has_purchase_order"
    t.index ["has_purchase_request"], name: "index_olap_facts_spends_on_has_purchase_request"
    t.index ["igst_percentage"], name: "index_olap_facts_spends_on_igst_percentage"
    t.index ["is_composite_vendor"], name: "index_olap_facts_spends_on_is_composite_vendor"
    t.index ["is_delivered_on_time"], name: "index_olap_facts_spends_on_is_delivered_on_time"
    t.index ["is_employee_expense"], name: "index_olap_facts_spends_on_is_employee_expense"
    t.index ["is_exceeding_budget"], name: "index_olap_facts_spends_on_is_exceeding_budget"
    t.index ["is_gst_registered"], name: "index_olap_facts_spends_on_is_gst_registered"
    t.index ["is_msme_registered"], name: "index_olap_facts_spends_on_is_msme_registered"
    t.index ["is_reimbursement"], name: "index_olap_facts_spends_on_is_reimbursement"
    t.index ["is_vendor_payment"], name: "index_olap_facts_spends_on_is_vendor_payment"
    t.index ["item_type"], name: "index_olap_facts_spends_on_item_type"
    t.index ["payment_mode"], name: "index_olap_facts_spends_on_payment_mode"
    t.index ["quantity_cancelled"], name: "index_olap_facts_spends_on_quantity_cancelled"
    t.index ["quantity_cancelled_percentage"], name: "index_olap_facts_spends_on_quantity_cancelled_percentage"
    t.index ["quantity_delivered_late"], name: "index_olap_facts_spends_on_quantity_delivered_late"
    t.index ["quantity_delivered_late_percentage"], name: "index_olap_facts_spends_on_quantity_delivered_late_percentage"
    t.index ["quantity_delivered_on_time"], name: "index_olap_facts_spends_on_quantity_delivered_on_time"
    t.index ["quantity_delivered_on_time_percentage"], name: "index_olap_facts_spends_on_quantity_delivered_on_time_percentage"
    t.index ["quantity_invoiced"], name: "index_olap_facts_spends_on_quantity_invoiced"
    t.index ["quantity_invoiced_percentage"], name: "index_olap_facts_spends_on_quantity_invoiced_percentage"
    t.index ["quantity_issued_from_inventory"], name: "index_olap_facts_spends_on_quantity_issued_from_inventory"
    t.index ["quantity_paid"], name: "index_olap_facts_spends_on_quantity_paid"
    t.index ["quantity_paid_percentage"], name: "index_olap_facts_spends_on_quantity_paid_percentage"
    t.index ["quantity_pending_invoice"], name: "index_olap_facts_spends_on_quantity_pending_invoice"
    t.index ["quantity_pending_payment"], name: "index_olap_facts_spends_on_quantity_pending_payment"
    t.index ["quantity_pending_purchase"], name: "index_olap_facts_spends_on_quantity_pending_purchase"
    t.index ["quantity_pending_receipt"], name: "index_olap_facts_spends_on_quantity_pending_receipt"
    t.index ["quantity_purchased"], name: "index_olap_facts_spends_on_quantity_purchased"
    t.index ["quantity_purchased_percentage"], name: "index_olap_facts_spends_on_quantity_purchased_percentage"
    t.index ["quantity_received"], name: "index_olap_facts_spends_on_quantity_received"
    t.index ["quantity_received_percentage"], name: "index_olap_facts_spends_on_quantity_received_percentage"
    t.index ["quantity_requested"], name: "index_olap_facts_spends_on_quantity_requested"
    t.index ["sgst_percentage"], name: "index_olap_facts_spends_on_sgst_percentage"
    t.index ["tax_percentage"], name: "index_olap_facts_spends_on_tax_percentage"
    t.index ["tax_type"], name: "index_olap_facts_spends_on_tax_type"
    t.index ["updated_at"], name: "index_olap_facts_spends_on_updated_at"
    t.index ["vendor_name"], name: "index_olap_facts_spends_on_vendor_name"
  end

end
