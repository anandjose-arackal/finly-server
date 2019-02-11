class AddAmountToCardLimits < ActiveRecord::Migration[4.2]
  def change
    add_column :card_limits, :amount, :decimal
  end
end
