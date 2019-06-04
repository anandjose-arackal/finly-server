class ChangeLengthOfProcurementTermText < ActiveRecord::Migration[5.2]
  def change
    change_column :purchase_orders, :procurement_term_text, :text, limit: 16.megabytes - 1
  end
end
