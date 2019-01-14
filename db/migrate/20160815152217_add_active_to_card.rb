class AddActiveToCard < ActiveRecord::Migration[4.2]
  def change
    add_column :cards, :active, :boolean
  end
end
