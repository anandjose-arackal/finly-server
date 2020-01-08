class MakeCnaSoftDeletable < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_note_adjustments, :deleted_at, :datetime, index: true
  end
end
