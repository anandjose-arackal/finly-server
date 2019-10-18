class CreateBbpsBillers < ActiveRecord::Migration[5.2]
  def change
    create_table :bbps_billers do |t|
     t.string :biller_id, index: true
     t.string :biller_name
     t.string :biller_alias_name
     t.string :biller_category_name
     t.string :biller_mode
     t.boolean :biller_accepts_adhoc
     t.boolean :parent_biller
     t.string :parent_biller_id, index: true
     t.string :biller_owner_shp
     t.string :biller_coverage
     t.string :fetch_requirement
     t.string :payment_amount_exactness
     t.string :support_bill_validation
     t.date :biller_effctv_from
     t.date :biller_effctv_to
     t.date :biller_temp_deactivation_start
     t.date :biller_temp_deactivation_end
     t.text :biller_payment_modes, limit: 4294967295
     t.text :biller_payment_channels, limit: 4294967295
     t.text :biller_customer_params, limit: 4294967295
     t.text :biller_response_params, limit: 4294967295
     t.text :biller_additional_info, limit: 4294967295
     t.text :interchange_fee_conf, limit: 4294967295
     t.text :interchange_fee, limit: 4294967295
     t.string :status, index: true
     t.text :biller_description
     t.string :support_deemed
     t.string :support_pending_status
     t.string :biller_time_out

      t.timestamps index: true, null: false
    end
  end
end
