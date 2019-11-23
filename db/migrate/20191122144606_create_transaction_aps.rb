class CreateTransactionAps < ActiveRecord::Migration[5.2]
  def change
    create_table :transaction_aps do |t|
      t.integer :company_id, index: true
      t.string :company_name, index: true

      t.integer :transaction_id, index: true
      t.string :transaction_type, index: true

      t.integer :transaction_parent_id, index: true
      t.string :transaction_parent_type, index: true

      t.integer :category_id, index: true
      t.string :category_name, index: true
      t.string :gl_code, index: true
      t.string :gl_description, index: true

      t.integer :cost_center_id, index: true
      t.string :cost_center_name, index: true

      t.integer :parent_billing_location_id, index: true
      t.string :parent_billing_location_name, index: true

      t.integer :billing_location_id, index: true
      t.string :billing_location_name, index: true

      t.integer :parent_shipping_location_id, index: true
      t.string :parent_shipping_location_name, index: true

      t.integer :shipping_location_id, index: true
      t.string :shipping_location_name, index: true

      t.integer :parent_department_id, index: true
      t.string :parent_department_name, index: true

      t.integer :department_id, index: true
      t.string :department_name, index: true

      t.integer :vendor_id, index: true
      t.string :vendor_name, index: true
      t.string :vendor_legal_name, index: true
      t.integer :vendor_location_id, index: true
      t.string :vendor_location_name, index: true
      t.boolean :is_vendor_msme_registered, index: true
      t.string :vendor_gstin, index: true
      t.boolean :is_vendor_composite, index: true


      t.integer :initiating_account_id, index: true
      t.string :initiating_account_name, index: true

      t.integer :receiving_account_id, index: true
      t.string :receiving_account_name, index: true
      t.string :payment_mode
      t.string :transaction_reference_id

      t.integer :user_id, index: true
      t.integer :user_finly_id, index: true
      t.string :user_first_name, index: true
      t.string :user_last_name, index: true
      t.string :user_email, index: true
      t.string :user_mobile_number, index: true
      t.string :user_employee_id, index: true
      t.integer :user_department_id, index: true
      t.integer :user_department_name, index: true
      t.integer :user_location_id, index: true
      t.integer :user_location_name, index: true
      t.integer :user_cost_center_id, index: true
      t.integer :user_cost_center_name, index: true

      t.datetime :transaction_date, index: true
      t.datetime :transaction_created_at, index: true
      t.datetime :transaction_updated_at, index: true
      t.datetime :transaction_submitted_at, index: true
      t.datetime :transaction_approved_at, index: true
      t.datetime :transaction_line_number, index: true

      t.integer :approval_time, index: true
      t.integer :number_of_rejections, index: true

      t.integer :procurement_id, index: true
      t.string :procurement_name, index: true

      t.string :transaction_status, index: true


      t.integer :amount_id, index: true
      t.decimal :amount_value, index: true, :precision => 20, :scale => 5
      t.string :amount_currency, index: true

      t.integer :amount_basic_id, index: true
      t.decimal :amount_basic_value, index: true, :precision => 20, :scale => 5
      t.string :amount_basic_currency, index: true

      t.integer :amount_tax_id, index: true
      t.decimal :amount_tax_value, index: true, :precision => 20, :scale => 5
      t.string :amount_tax_currency, index: true

      t.integer :amount_net_id, index: true
      t.decimal :amount_net_value, index: true, :precision => 20, :scale => 5
      t.string :amount_net_currency, index: true


      t.integer :amount_csgt_id, index: true
      t.decimal :amount_csgt_value, index: true, :precision => 20, :scale => 5
      t.string :amount_csgt_currency, index: true

      t.integer :amount_sgst_id, index: true
      t.decimal :amount_sgst_value, index: true, :precision => 20, :scale => 5
      t.string :amount_sgst_currency, index: true

      t.integer :amount_igst_id, index: true
      t.decimal :amount_igst_value, index: true, :precision => 20, :scale => 5
      t.string :amount_igst_currency, index: true

      t.integer :amount_tds_id, index: true
      t.decimal :amount_tds_value, index: true, :precision => 20, :scale => 5
      t.string :amount_tds_currency, index: true

      t.integer :credit_days, index: true
      t.decimal :advance_percentage, index: true

      t.string :document_number, index: true

      t.integer :item_id, index: true
      t.string :item_name, index: true
      t.string :item_hsn_sac, index: true
      t.string :item_description, index: true
      t.string :item_quantity, index: true

      t.integer :item_rate_id, index: true
      t.decimal :item_rate_value, index: true, :precision => 20, :scale => 5
      t.string :item_rate_currency, index: true

      t.integer :rate_contract_id, index: true
      t.integer :tax_rate_id, index: true
      t.integer :cgst_rate_id, index: true
      t.integer :sgst_rate_id, index: true
      t.integer :igst_rate_id, index: true
      t.integer :tds_rate_id, index: true

      t.integer :policy_id, index: true

      t.string :reviewal_level_1_name
      t.integer :reviewal_level_1_user_id, index: true
      t.integer :reviewal_level_1_user_finly_id, index: true
      t.string :reviewal_level_1_user_first_name, index: true
      t.string :reviewal_level_1_user_last_name, index: true
      t.string :reviewal_level_1_user_email, index: true
      t.string :reviewal_level_1_user_mobile_number, index: true
      t.string :reviewal_level_1_user_employee_id, index: true
      t.integer :reviewal_level_1_user_department_id, index: true
      t.integer :reviewal_level_1_user_department_name, index: true
      t.integer :reviewal_level_1_user_location_id, index: true
      t.integer :reviewal_level_1_user_location_name, index: true
      t.integer :reviewal_level_1_user_cost_center_id, index: true
      t.integer :reviewal_level_1_user_cost_center_name, index: true

      t.string :reviewal_level_2_name
      t.integer :reviewal_level_2_user_id, index: true
      t.integer :reviewal_level_2_user_finly_id, index: true
      t.string :reviewal_level_2_user_first_name, index: true
      t.string :reviewal_level_2_user_last_name, index: true
      t.string :reviewal_level_2_user_email, index: true
      t.string :reviewal_level_2_user_mobile_number, index: true
      t.string :reviewal_level_2_user_employee_id, index: true
      t.integer :reviewal_level_2_user_department_id, index: true
      t.integer :reviewal_level_2_user_department_name, index: true
      t.integer :reviewal_level_2_user_location_id, index: true
      t.integer :reviewal_level_2_user_location_name, index: true
      t.integer :reviewal_level_2_user_cost_center_id, index: true
      t.integer :reviewal_level_2_user_cost_center_name, index: true

      t.string :reviewal_level_3_name
      t.integer :reviewal_level_3_user_id, index: true
      t.integer :reviewal_level_3_user_finly_id, index: true
      t.string :reviewal_level_3_user_first_name, index: true
      t.string :reviewal_level_3_user_last_name, index: true
      t.string :reviewal_level_3_user_email, index: true
      t.string :reviewal_level_3_user_mobile_number, index: true
      t.string :reviewal_level_3_user_employee_id, index: true
      t.integer :reviewal_level_3_user_department_id, index: true
      t.integer :reviewal_level_3_user_department_name, index: true
      t.integer :reviewal_level_3_user_location_id, index: true
      t.integer :reviewal_level_3_user_location_name, index: true
      t.integer :reviewal_level_3_user_cost_center_id, index: true
      t.integer :reviewal_level_3_user_cost_center_name, index: true

      t.string :reviewal_level_4_name
      t.integer :reviewal_level_4_user_id, index: true
      t.integer :reviewal_level_4_user_finly_id, index: true
      t.string :reviewal_level_4_user_first_name, index: true
      t.string :reviewal_level_4_user_last_name, index: true
      t.string :reviewal_level_4_user_email, index: true
      t.string :reviewal_level_4_user_mobile_number, index: true
      t.string :reviewal_level_4_user_employee_id, index: true
      t.integer :reviewal_level_4_user_department_id, index: true
      t.integer :reviewal_level_4_user_department_name, index: true
      t.integer :reviewal_level_4_user_location_id, index: true
      t.integer :reviewal_level_4_user_location_name, index: true
      t.integer :reviewal_level_4_user_cost_center_id, index: true
      t.integer :reviewal_level_4_user_cost_center_name, index: true

      t.string :reviewal_level_5_name
      t.integer :reviewal_level_5_user_id, index: true
      t.integer :reviewal_level_5_user_finly_id, index: true
      t.string :reviewal_level_5_user_first_name, index: true
      t.string :reviewal_level_5_user_last_name, index: true
      t.string :reviewal_level_5_user_email, index: true
      t.string :reviewal_level_5_user_mobile_number, index: true
      t.string :reviewal_level_5_user_employee_id, index: true
      t.integer :reviewal_level_5_user_department_id, index: true
      t.integer :reviewal_level_5_user_department_name, index: true
      t.integer :reviewal_level_5_user_location_id, index: true
      t.integer :reviewal_level_5_user_location_name, index: true
      t.integer :reviewal_level_5_user_cost_center_id, index: true
      t.integer :reviewal_level_5_user_cost_center_name, index: true

      t.string :reviewal_level_6_name
      t.integer :reviewal_level_6_user_id, index: true
      t.integer :reviewal_level_6_user_finly_id, index: true
      t.string :reviewal_level_6_user_first_name, index: true
      t.string :reviewal_level_6_user_last_name, index: true
      t.string :reviewal_level_6_user_email, index: true
      t.string :reviewal_level_6_user_mobile_number, index: true
      t.string :reviewal_level_6_user_employee_id, index: true
      t.integer :reviewal_level_6_user_department_id, index: true
      t.integer :reviewal_level_6_user_department_name, index: true
      t.integer :reviewal_level_6_user_location_id, index: true
      t.integer :reviewal_level_6_user_location_name, index: true
      t.integer :reviewal_level_6_user_cost_center_id, index: true
      t.integer :reviewal_level_6_user_cost_center_name, index: true

      t.string :reviewal_level_7_name
      t.integer :reviewal_level_7_user_id, index: true
      t.integer :reviewal_level_7_user_finly_id, index: true
      t.string :reviewal_level_7_user_first_name, index: true
      t.string :reviewal_level_7_user_last_name, index: true
      t.string :reviewal_level_7_user_email, index: true
      t.string :reviewal_level_7_user_mobile_number, index: true
      t.string :reviewal_level_7_user_employee_id, index: true
      t.integer :reviewal_level_7_user_department_id, index: true
      t.integer :reviewal_level_7_user_department_name, index: true
      t.integer :reviewal_level_7_user_location_id, index: true
      t.integer :reviewal_level_7_user_location_name, index: true
      t.integer :reviewal_level_7_user_cost_center_id, index: true
      t.integer :reviewal_level_7_user_cost_center_name, index: true

      t.string :reviewal_level_8_name
      t.integer :reviewal_level_8_user_id, index: true
      t.integer :reviewal_level_8_user_finly_id, index: true
      t.string :reviewal_level_8_user_first_name, index: true
      t.string :reviewal_level_8_user_last_name, index: true
      t.string :reviewal_level_8_user_email, index: true
      t.string :reviewal_level_8_user_mobile_number, index: true
      t.string :reviewal_level_8_user_employee_id, index: true
      t.integer :reviewal_level_8_user_department_id, index: true
      t.integer :reviewal_level_8_user_department_name, index: true
      t.integer :reviewal_level_8_user_location_id, index: true
      t.integer :reviewal_level_8_user_location_name, index: true
      t.integer :reviewal_level_8_user_cost_center_id, index: true
      t.integer :reviewal_level_8_user_cost_center_name, index: true

      t.string :reviewal_level_8_name
      t.integer :reviewal_level_8_user_id, index: true
      t.integer :reviewal_level_8_user_finly_id, index: true
      t.string :reviewal_level_8_user_first_name, index: true
      t.string :reviewal_level_8_user_last_name, index: true
      t.string :reviewal_level_8_user_email, index: true
      t.string :reviewal_level_8_user_mobile_number, index: true
      t.string :reviewal_level_8_user_employee_id, index: true
      t.integer :reviewal_level_8_user_department_id, index: true
      t.integer :reviewal_level_8_user_department_name, index: true
      t.integer :reviewal_level_8_user_location_id, index: true
      t.integer :reviewal_level_8_user_location_name, index: true
      t.integer :reviewal_level_8_user_cost_center_id, index: true
      t.integer :reviewal_level_8_user_cost_center_name, index: true

      t.timestamps
    end
  end
end
