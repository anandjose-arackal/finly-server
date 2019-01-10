class AddSurchargeToExpenses < ActiveRecord::Migration[4.2]
  def change
    add_column :card_expenses, :surcharge_id, :integer, foreign_key: true, index: true
  end
end
