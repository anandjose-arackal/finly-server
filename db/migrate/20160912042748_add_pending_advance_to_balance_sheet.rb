class AddPendingAdvanceToBalanceSheet < ActiveRecord::Migration
  def change
    add_column :balance_sheets, :pending_advance_id, :integer, :references => 'Amount', index: true, foreign_key: true
  end
end
