class AddCnaFieldsForForms < ActiveRecord::Migration[6.0]
  def change
    add_column :credit_note_adjustments, :cn_net_adjustable_amount, :decimal, precision: 20, scale: 10, default: 0
    add_column :credit_note_adjustments, :cn_adjustment_amount, :decimal, precision: 20, scale: 10, default: 0
  end
end
