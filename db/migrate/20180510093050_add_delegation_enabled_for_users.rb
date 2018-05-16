class AddDelegationEnabledForUsers < ActiveRecord::Migration
  def change
    add_column :users, :delegation_enabled, :boolean
  end
end
