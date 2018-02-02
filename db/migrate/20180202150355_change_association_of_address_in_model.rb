class ChangeAssociationOfAddressInModel < ActiveRecord::Migration
  def change
    change_column :addresses, :state_id, :integer, references: "GstStateCode", foreign_key: true, index: true
  end
end
