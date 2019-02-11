class AddOrderToLocation < ActiveRecord::Migration[4.2]
  def change
    add_column :locations, :order, :integer, index: true
  end
end
