class AddProductCodeDCodeToCards < ActiveRecord::Migration[4.2]
  def change
    add_column :cards, :product_code, :string, null: false
    add_column :companies, :d_code, :string
  end
end
