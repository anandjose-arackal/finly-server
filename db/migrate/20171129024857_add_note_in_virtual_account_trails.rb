class AddNoteInVirtualAccountTrails < ActiveRecord::Migration
  def change
    add_column :virtual_account_collect_trails, :note, :text
    add_column :payment_receivable_transaction_trails, :note, :text
  end
end
