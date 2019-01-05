class AddAutoApproveInMoneyRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :money_requests, :auto_approve, :boolean
  end
end
