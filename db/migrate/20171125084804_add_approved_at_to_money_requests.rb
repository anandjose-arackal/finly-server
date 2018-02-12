class AddApprovedAtToMoneyRequests < ActiveRecord::Migration
  def change
    add_column :money_requests, :approved_at, :datetime
  end
end
