class RemoveForeignKeyBetweenCardRestrictionsAndUser < ActiveRecord::Migration
  def change
    # remove_foreign_key :card_restrictions,  column: :card_id
    # add_foreign_key :card_restrictions, :cards
  end
end
