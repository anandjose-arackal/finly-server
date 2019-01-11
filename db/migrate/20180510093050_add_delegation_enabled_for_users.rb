class AddDelegationEnabledForUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :delegation_enabled, :boolean
  end
end
