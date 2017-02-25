class RenameCashOnHandToCashInHand < ActiveRecord::Migration
  def change
    rename_column :balance_sheets, :cash_on_hand_id, :cash_in_hand_id
  end
end
