class AddPrepaidCardsToProductPricingQueries < ActiveRecord::Migration
  def change
    add_column :product_pricing_queries, :prepaid_cards, :string
  end
end
