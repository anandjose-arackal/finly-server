class ChangeAmountInCardLimit < ActiveRecord::Migration[4.2]
  def change
    remove_column :card_limits, :amount_id
    remove_column :card_limits, :amount
    add_column :card_limits, :budget, :decimal
  end
end
