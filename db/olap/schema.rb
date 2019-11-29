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

ActiveRecord::Schema.define(version: 2019_11_28_120435) do

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

end
