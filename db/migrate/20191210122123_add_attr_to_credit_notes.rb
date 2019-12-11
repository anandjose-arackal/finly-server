class AddAttrToCreditNotes < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_notes, :deleted_at, :datetime, index: true
    add_column :credit_notes, :gst_type_id, references:
  end
end
