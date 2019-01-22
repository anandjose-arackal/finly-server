class RenameUserIdToCardIdInCardRestrictions < ActiveRecord::Migration[4.2]
  def change
    remove_foreign_key :card_restrictions,  column: :user_id
    rename_column :card_restrictions, :user_id, :card_id
    add_foreign_key :card_restrictions, :cards
  end
end
