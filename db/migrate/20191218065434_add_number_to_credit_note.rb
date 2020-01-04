class AddNumberToCreditNote < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_notes, :credit_note_number, :string, index: true
  end
end
