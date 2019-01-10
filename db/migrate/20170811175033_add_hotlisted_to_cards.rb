class AddHotlistedToCards < ActiveRecord::Migration[4.2]
  def change
    add_column :cards, :hotlisted, :boolean, default: false
  end
end
