class AddIsActiveFundsLoadRequestType < ActiveRecord::Migration
  def change
    add_column :company_funds_load_requests, :is_active, :boolean, default: true
  end
end
