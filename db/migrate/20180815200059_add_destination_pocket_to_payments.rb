class AddDestinationPocketToPayments < ActiveRecord::Migration[4.2]
  def change
    add_column :payments, :destination_pocket_id, :integer, references: "UserPocket", foreign_key: true, index: true
  end
end