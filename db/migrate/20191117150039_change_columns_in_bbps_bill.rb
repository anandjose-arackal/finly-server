class ChangeColumnsInBbpsBill < ActiveRecord::Migration[5.2]
  def change
    add_column :bbps_bills, :total_amount_id, :integer, references: 'Amount', foreign_key: true, index: true
    rename_column :bbps_bills, :fixed_charge_id, :early_payment_fee_id
    rename_column :bbps_bills, :additional_charge_id, :convenience_fee_id

    add_column :bbps_bills, :early_payment_fee_selected, :boolean, default: false
    add_column :bbps_bills, :late_payment_fee_selected, :boolean, default: false
    add_column :bbps_bills, :convenience_fee_selected, :boolean, default: false
  end
end
