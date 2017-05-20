class AddBaseCurrencyToPolicyAndCompany < ActiveRecord::Migration
  def change
    add_column :policies, :base_currency_id, :integer, default: 1, references: "Currency", foreign_key: true, index: true
    add_column :companies, :base_currency_id, :integer, default: 1, references: "Currency", foreign_key: true, index: true
  end
end
