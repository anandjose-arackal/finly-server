class RemoveReimbursementAmountAndAddOtherColumns < ActiveRecord::Migration
  def change
    remove_column :reports, :reimbursement_amount_id
    add_column :reports, :cash_expenses_total_id, :integer, foreign_key: true, index: true
    add_column :reports, :card_expenses_total_id, :integer, foreign_key: true, index: true
  end
end
