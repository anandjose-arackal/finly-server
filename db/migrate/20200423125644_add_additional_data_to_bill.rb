class AddAdditionalDataToBill < ActiveRecord::Migration[5.2]
  def change
    add_column :bbps_bills, :disconn_tag, :string
    add_column :bbps_bills, :bill_month, :string
    add_column :bbps_bills, :pc, :string
    add_column :bbps_bills, :early_payment_date, :date
    add_column :bbps_bills, :api_response, :text
  end
end
