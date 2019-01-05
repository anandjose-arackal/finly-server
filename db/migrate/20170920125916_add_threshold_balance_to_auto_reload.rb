class AddThresholdBalanceToAutoReload < ActiveRecord::Migration[4.2]
  def change
    add_column :auto_reload_configs, :threshold_balance_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end