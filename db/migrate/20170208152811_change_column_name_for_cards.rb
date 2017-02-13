class ChangeColumnNameForCards < ActiveRecord::Migration
  def change
    rename_column :cards, :balance_id, :card_balance_id
  end
end
