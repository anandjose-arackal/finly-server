class AddProductToProductPricingQueries < ActiveRecord::Migration[4.2]
  def change
    add_column :product_pricing_queries, :product, :string
  end
end
