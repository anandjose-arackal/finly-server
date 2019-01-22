class AddApprovedAtToMoneyRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :money_requests, :approved_at, :datetime
  end
end
