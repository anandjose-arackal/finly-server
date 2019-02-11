class AddLockedToCards < ActiveRecord::Migration[4.2]
  def change
    add_column :cards, :card_processor_status, :string, index: true
  end
end