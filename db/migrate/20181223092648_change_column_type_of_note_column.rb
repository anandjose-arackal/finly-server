class ChangeColumnTypeOfNoteColumn < ActiveRecord::Migration
  def change
    change_column :transaction_details, :note, "VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_bin"
  end
end
