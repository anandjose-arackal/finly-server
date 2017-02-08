class AddMccRestrictionTypeToCardRestrictions < ActiveRecord::Migration
  def change
    add_column :card_restrictions, :mcc_restriction_type, :string
  end
end
