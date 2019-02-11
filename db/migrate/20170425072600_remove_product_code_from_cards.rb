class RemoveProductCodeFromCards < ActiveRecord::Migration[4.2]
  def change
    remove_column :cards, :product_code
  end
end
