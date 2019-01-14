class AddSettlementCurrencyToPolicy < ActiveRecord::Migration[4.2]
  def change
    add_column :policies, :settlement_currency_id, :integer, references: 'Currency', index: true, foreign_key: true, null: false, default: 1
  end
end
