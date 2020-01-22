class AddAttrToBbpsBill < ActiveRecord::Migration[5.2]
  def change
    add_column :bbps_bills, :bill_validation_required, :boolean, index: true
  end
end
