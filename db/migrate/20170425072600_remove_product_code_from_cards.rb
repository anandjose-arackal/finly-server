class RemoveProductCodeFromCards < ActiveRecord::Migration
  def change
    remove_column :cards, :product_code
  end
end
