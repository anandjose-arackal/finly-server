class AddTargetBalanceToAutoReloadConfigs < ActiveRecord::Migration
  def change
    add_column :auto_reload_configs, :target_balance_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end
