class ChangeDummyToCardEverywhere < ActiveRecord::Migration
  def change
    rename_column :card_limits, :dummy_restriction_id, :card_restriction_id
  end
end
