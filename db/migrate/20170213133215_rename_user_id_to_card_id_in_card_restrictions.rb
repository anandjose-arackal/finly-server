class RenameUserIdToCardIdInCardRestrictions < ActiveRecord::Migration
  def change
    rename_column :card_restrictions, :user_id, :card_id
  end
end
