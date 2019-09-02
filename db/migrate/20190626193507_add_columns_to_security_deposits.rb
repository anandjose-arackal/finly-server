class AddColumnsToSecurityDeposits < ActiveRecord::Migration[5.2]
  def change
    add_column :security_deposits, :company_id, :integer
    add_index :security_deposits, :company_id
    add_column :security_deposits, :creator_id, :integer
    add_index :security_deposits, :creator_id
  end
end
