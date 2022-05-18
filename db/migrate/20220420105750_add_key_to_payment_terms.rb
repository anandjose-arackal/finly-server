class AddKeyToPaymentTerms < ActiveRecord::Migration[6.0]
  def change
    add_column :payment_terms, :key, :string
  end
end
