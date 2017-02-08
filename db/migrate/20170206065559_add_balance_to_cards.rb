class AddBalanceToCards < ActiveRecord::Migration
  def change
    add_column :cards, :balance_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end
