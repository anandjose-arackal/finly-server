class AddProductToProductPricingQueries < ActiveRecord::Migration
  def change
    add_column :product_pricing_queries, :product, :string
  end
end
