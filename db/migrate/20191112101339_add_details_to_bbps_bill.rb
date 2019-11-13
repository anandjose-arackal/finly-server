class AddDetailsToBbpsBill < ActiveRecord::Migration[5.2]
  def change
    add_column :bbps_bills, :due_date, :date, index: true
    add_column :bbps_bills, :bill_date, :date, index: true
    add_column :bbps_bills, :bill_number, :string, index: true
    add_column :bbps_bills, :paid_on_date, :date
    add_column :bbps_bills, :transaction_id, :string
    add_column :bbps_bills, :bbps_id, :string
  end
end


required(:amount).filled
required(:bill_date).filled
required(:due_date).filled
required(:bill_number).filled
required(:bill_period).filled
required(:biller_id).filled