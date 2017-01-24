class AddAmountToCardLimits < ActiveRecord::Migration
  def change
    add_column :card_limits, :amount, :decimal
  end
end
