class AddOrderToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :order, :integer, index: true
  end
end
