class RenameUserIdToCardIdInCardRestrictions < ActiveRecord::Migration
  def change
    # remove_foreign_key :card_restrictions, :users
    # rename_column :card_restrictions, :user_id, :card_id
    add_foreign_key :card_restrictions, :cards
  end
end
