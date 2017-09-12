class AddLockedToCards < ActiveRecord::Migration
  def change
    add_column :cards, :yse_status, :string, index: true
  end
end