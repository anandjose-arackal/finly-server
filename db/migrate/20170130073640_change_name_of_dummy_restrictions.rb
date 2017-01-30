class ChangeNameOfDummyRestrictions < ActiveRecord::Migration
  def change
    rename_table :dummy_restrictions, :card_restrictions
  end
end
