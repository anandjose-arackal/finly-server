class AddPrepaidCardsToProductPricingQueries < ActiveRecord::Migration[4.2]
  def change
    add_column :product_pricing_queries, :prepaid_cards, :string
  end
end
