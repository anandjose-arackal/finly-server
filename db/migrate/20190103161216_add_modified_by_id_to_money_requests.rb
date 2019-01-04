class AddModifiedByIdToMoneyRequests < ActiveRecord::Migration
  def change
    add_column :money_requests, :modified_by_id, :integer
  end
end
