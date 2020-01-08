class ChangeQuickPayInBbpsBill < ActiveRecord::Migration[5.2]
  def change
    change_column :bbps_bills, :quick_pay, :string, default: "N"
  end
end
