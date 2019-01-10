class RenameCashInHandToCashOnHand < ActiveRecord::Migration[4.2]
  def change
  rename_column :balance_sheets, :cash_in_hand_id, :cash_on_hand_id
  end
end
