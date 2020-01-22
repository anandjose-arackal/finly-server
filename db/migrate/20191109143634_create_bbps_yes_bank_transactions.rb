class CreateBbpsYesBankTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :bbps_yes_bank_transactions do |t|
      fields_list = 
      [:message_code, :status, :error_code, :error_desc, :ref_no, :agent_institution_id, :channel_id,
        :bbps_ref_id, :agent_id, :customer_name, :customer_mobile, :customer_email, :customer_aadhar_no, :customer_pan_id,
        :channel_id, :biller_id, :amount, :bill_date, :due_date, :bill_number, :bill_period, :convenience_fee,
        :convenience_fee_desc, :late_payment_fee, :early_payment_fee,
        :additional_field, :additional_field, :additional_field, :additional_field, :additional_field,
        :additional_field]
      fields_list.each do |field|
        t.string field
      end
      t.integer :bill_id, references: "BbpsBill", foreign_key: true, index: true    
      t.integer :company_id, references: "Company", foreign_key: true, index: true
      t.timestamps
    end
  end
end
