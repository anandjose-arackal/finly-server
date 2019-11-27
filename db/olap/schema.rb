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

ActiveRecord::Schema.define(version: 2019_11_26_092139) do

  create_table "olap_dimensions_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "finly_ref_id", null: false
    t.datetime "finly_ref_created_at"
    t.datetime "finly_ref_updated_at"
    t.string "name"
    t.string "gl_code"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_olap_dimensions_categories_on_active"
    t.index ["created_at"], name: "index_olap_dimensions_categories_on_created_at"
    t.index ["finly_ref_created_at"], name: "index_olap_dimensions_categories_on_finly_ref_created_at"
    t.index ["finly_ref_id"], name: "index_olap_dimensions_categories_on_finly_ref_id"
    t.index ["finly_ref_updated_at"], name: "index_olap_dimensions_categories_on_finly_ref_updated_at"
    t.index ["gl_code"], name: "index_olap_dimensions_categories_on_gl_code"
    t.index ["name"], name: "index_olap_dimensions_categories_on_name"
    t.index ["updated_at"], name: "index_olap_dimensions_categories_on_updated_at"
  end

end
