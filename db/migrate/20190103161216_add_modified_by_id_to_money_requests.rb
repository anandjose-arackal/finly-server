class AddModifiedByIdToMoneyRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :money_requests, :modified_by_id, :integer
  end
end
