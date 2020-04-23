class AddAdditionalDataToBill < ActiveRecord::Migration[5.2]
  def change
    add_column :bbps_bills, :disconnection_ta, :string
    add_column :bbps_bills, :bill_month, type: string
    add_column :bbps_bills, :pc, :string
    add_column :bbps_bills, :early_payment_date, :date
  end
end
