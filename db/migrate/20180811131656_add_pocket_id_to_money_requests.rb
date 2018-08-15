class AddPocketIdToMoneyRequests < ActiveRecord::Migration
  def change
    add_column :money_requests, :destination_pocket_id, :integer, references: "UserPocket", foreign_key: true, index: true
  end
end