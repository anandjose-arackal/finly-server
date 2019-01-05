class CreateProductPricingQueries < ActiveRecord::Migration[4.2]
  def change
    create_table :product_pricing_queries do |t|
      t.string :name
      t.string :mobile_number
      t.string :email
      t.string :employees
      t.string :accounting_system
      t.string :monthly_transactions
      t.string :monthly_invoices

      t.timestamps null: false
    end
  end
end
