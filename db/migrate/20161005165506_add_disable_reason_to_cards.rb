class AddDisableReasonToCards < ActiveRecord::Migration
  def change
    add_column :cards, :disable_note, :text
  end
end
