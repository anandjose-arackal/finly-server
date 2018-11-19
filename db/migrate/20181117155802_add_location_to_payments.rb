class AddLocationToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :location_id, :integer, references: "BranchLocation", foreign_key: true, index: true
  end
end