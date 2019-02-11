class AddMccRestrictionTypeToCardRestrictions < ActiveRecord::Migration[4.2]
  def change
    add_column :card_restrictions, :mcc_restriction_type, :string
  end
end
