class AddDisableReasonToCards < ActiveRecord::Migration[4.2]
  def change
    add_column :cards, :disable_note, :text
  end
end
