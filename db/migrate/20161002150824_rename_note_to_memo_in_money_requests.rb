class RenameNoteToMemoInMoneyRequests < ActiveRecord::Migration
  def change
    rename_column :money_requests, :note, :memo
  end
end
