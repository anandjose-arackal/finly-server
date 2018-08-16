class AddBaseCurrencyIdToUserPockets < ActiveRecord::Migration
  def change
    add_column :user_pockets, :base_currency_id, :integer, references: "UserPocket", foreign_key: true, index: true
  end
end
