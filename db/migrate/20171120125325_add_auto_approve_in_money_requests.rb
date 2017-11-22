class AddAutoApproveInMoneyRequests < ActiveRecord::Migration
  def change
    add_column :money_requests, :auto_approve, :boolean
  end
end
