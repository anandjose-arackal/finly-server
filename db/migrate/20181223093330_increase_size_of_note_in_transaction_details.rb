class IncreaseSizeOfNoteInTransactionDetails < ActiveRecord::Migration[4.2]
  def change
    change_column :transaction_details, :note, "TEXT(65535) CHARACTER SET utf8 COLLATE utf8_bin"
  end
end
