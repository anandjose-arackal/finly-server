class AddLockedToCards < ActiveRecord::Migration
  def change
    add_column :cards, :card_processor_status, :string, index: true
  end
end