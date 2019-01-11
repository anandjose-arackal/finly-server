class ModifyCardRestriction < ActiveRecord::Migration[4.2]
  def change
    remove_column :card_restrictions, :product_code_id
    add_column :card_restrictions, :mcc_group_id, :integer, index: true, foreign_key: true
  end
end
