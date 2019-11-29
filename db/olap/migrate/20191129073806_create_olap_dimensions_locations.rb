class CreateOlapDimensionsLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :olap_dimensions_locations do |t|
      t.olap_references

      t.string :name, index: true
      t.string :gstin, index: true
      t.string :pan, index: true
      t.integer :company_id, index: true
      t.text :address_1
      t.text :address_2
      t.string :city, index: true
      t.integer :state_id, index: true
      t.string :country, index: true
      t.string :pin, index: true
      t.string :contact_name, index: true
      t.string :contact_mobile_number, index: true
      t.boolean :is_deleted, index: true
      t.datetime :deleted_at, index: true
      t.string :location_code, index: true
      t.string :ancestry, index: true
      t.string :nature_of_office, index: true
      t.boolean :billable_location, index: true
      t.boolean :shippable_location, index: true
      t.string :gl_code, index: true

      t.timestamps index: true
    end

    create_table :olap_dimensions_cost_centers do |t|
      t.olap_references

      t.string :name, index: true
      t.string :application, index: true
      t.integer :company_id, index: true
      t.boolean :is_deleted, index: true
      t.datetime :deleted_at, index: true
      t.string :cost_center_code, index: true
      t.string :ancestry, index: true
      t.string :gl_code, index: true

      t.timestamps index: true
    end

    create_table :olap_dimensions_policies do |t|
      t.olap_references

      t.string :name, index: true
      t.integer :company_id, index: true
      t.integer :owner_id, index: true
      t.boolean :default, index: true
      t.boolean :is_deleted, index: true
      t.text :description
      t.integer :base_currency_id, index: true
      t.string :application, index: true
      t.integer :settlement_currency_id, index: true
      t.datetime :deleted_at, index: true

      t.timestamps index: true
    end

    create_table :olap_dimensions_items do |t|
      t.olap_references

      t.decimal :tax, index: true
      t.decimal :discount, index: true
      t.string :hsn_sac, index: true
      t.integer :company_id, index: true
      t.string :sku, index: true
      t.decimal :rate, index: true
      t.text :description
      t.integer :category_id, index: true
      t.text :note
      t.integer :tax_rate_id, index: true
      t.boolean :is_deleted, index: true
      t.string :item_code, index: true
      t.string :account, index: true
      t.integer :supply_item_type_id, index: true
      t.datetime :deleted_at, index: true
      t.integer :product_type_id, index: true
      t.string :item_number, index: true
      t.string :unit_of_measurement, index: true
      t.integer :user_id, index: true
      t.boolean :active, index: true
      t.integer :item_expense_type_id, index: true
      t.boolean :tds_applicable, index: true

      t.timestamps index: true
    end

    create_table :olap_dimensions_tax_rates do |t|
      t.olap_references

      t.string :name, index: true
      t.decimal :rate, index: true
      t.string :internal_id, index: true
      t.integer :company_id, index: true
      t.boolean :is_deleted, index: true
      t.datetime :deleted_at, index: true
      t.decimal :cgst, index: true
      t.decimal :sgst, index: true
      t.decimal :igst, index: true
      t.string :igst_internal_id, index: true
      t.string :cgst_internal_id, index: true
      t.string :sgst_internal_id, index: true

      t.timestamps index: true
    end

    create_table :olap_dimensions_tds_rates do |t|
      t.olap_references

      t.string :name, index: true
      t.decimal :tds, index: true
      t.integer :company_id, index: true
      t.string :gl_code, index: true
      t.datetime :deleted_at, index: true

      t.timestamps index: true
    end

    create_table :olap_dimensions_fiscal_times do |t|
      t.olap_references

      t.datetime :datetime, index: true
      t.date :date, index: true
      t.string :day_of_week, index: true
      t.integer :day_of_month, index: true
      t.integer :week, index: true
      t.integer :month, index: true
      t.string :quarter, index: true
      t.string :half, index: true
      t.integer :year, index: true
      t.integer :fiscal_year, index: true

      t.timestamps index: true
    end

    create_table :olap_dimensions_users do |t|
      t.olap_references

      t.string :email, index: true
      t.string :employee_id, index: true
      t.boolean :kyc_verified, index: true
      t.integer :company_id, index: true
      t.string :mobile_number, index: true
      t.boolean :active, index: true
      t.boolean :otp_verified, index: true
      t.string :first_name, index: true
      t.string :last_name, index: true
      t.boolean :mobile_only_invite, index: true
      t.boolean :verified, index: true
      t.boolean :default_password, index: true
      t.boolean :point_of_contact, index: true
      t.datetime :password_changed_at, index: true
      t.datetime :last_activity_at, index: true
      t.datetime :expired_at, index: true
      t.integer :cost_center_id, index: true
      t.integer :department_id, index: true
      t.integer :location_id, index: true
      t.integer :default_company_id, index: true
      t.string :finly_id, index: true

      t.timestamps index: true
    end
  end
end
