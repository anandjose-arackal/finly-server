class AddStatusIdToSecurityDeposits < ActiveRecord::Migration[5.2]
  def change
    add_column :security_deposits, :status_id, :integer
    add_index :security_deposits, :status_id
  end
end
