class RenameUserIdToCardIdInCardRestrictions < ActiveRecord::Migration
  def change
    remove_foreign_key :card_restrictions, :users
    rename_column :card_restrictions, :user_id, :card_id
    change_column :card_restrictions, :card_id, :int, foreign_key: true, index: true
  end
end
