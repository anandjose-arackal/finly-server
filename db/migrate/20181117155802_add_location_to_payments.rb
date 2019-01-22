class AddLocationToPayments < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :location_id, :integer, references: "BranchLocation", foreign_key: true, index: true
  end
end