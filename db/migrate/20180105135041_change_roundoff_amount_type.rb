class ChangeRoundoffAmountType < ActiveRecord::Migration
  def change
    rename_column :invoices, :roundoff_amount_id, :roundoff_amount
    change_column :invoices, :roundoff_amount, :decimal, precision: 20, scale: 10
  end
end
