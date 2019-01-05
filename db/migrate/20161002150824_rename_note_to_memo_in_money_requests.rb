class RenameNoteToMemoInMoneyRequests < ActiveRecord::Migration[4.2]
  def change
    rename_column :money_requests, :note, :memo
  end
end
