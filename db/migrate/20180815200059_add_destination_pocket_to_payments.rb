class AddDestinationPocketToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :destination_pocket_id, :integer, references: "UserPocket", foreign_key: true, index: true
  end
end