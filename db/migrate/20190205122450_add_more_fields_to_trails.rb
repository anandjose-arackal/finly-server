class AddMoreFieldsToTrails < ActiveRecord::Migration[5.2]
  def change
    add_column :trails, :cash_on_hand_deduction_id, :integer, references: "Payment", index: true, foreign_key: true
  end
end