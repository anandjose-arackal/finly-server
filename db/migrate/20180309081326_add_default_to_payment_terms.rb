class AddDefaultToPaymentTerms < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_terms, :default, :boolean
  end
end
