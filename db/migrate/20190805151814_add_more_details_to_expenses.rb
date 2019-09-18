class AddMoreDetailsToExpenses < ActiveRecord::Migration[5.2]
  def change
    add_column :expenses, :gstin_location_id, :integer, references: "GstinLocation", foreign_key: true, index: true
    add_column :expenses, :state_of_expense_id, :integer, references: "GstStateCode", foreign_key: true, index: true
    add_column :expenses, :hsn_sac, :string
    add_column :expenses, :merchant_bill_no, :string
  end
end