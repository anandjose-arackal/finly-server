class AddGstAmountToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :gst_amount_id, :integer, references: 'Amount', index: true, foreign_key: true
  end
end
