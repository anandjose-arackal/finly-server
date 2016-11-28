class AddSurchargeToExpenses < ActiveRecord::Migration
  def change
    add_column :card_expenses, :surcharge_id, :integer, foreign_key: true, index: true
  end
end
