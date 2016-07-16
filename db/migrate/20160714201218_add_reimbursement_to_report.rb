class AddReimbursementToReport < ActiveRecord::Migration
  def change
    add_column :reports, :reimbursement_id, :integer, :references => "Payment", index: true, foreign_key: true
    add_column :reports, :reimbursement_amount_id, :integer, :references => "Amount", index: true, foreign_key: true
    add_column :reports, :expense_total_id, :integer, :references => "Amount", index: true, foreign_key: true
    add_column :reports, :accounted, :boolean, default: false, null: false
  end
end
