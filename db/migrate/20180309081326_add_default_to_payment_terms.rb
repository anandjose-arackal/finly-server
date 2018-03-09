class AddDefaultToPaymentTerms < ActiveRecord::Migration
  def change
    add_column :payment_terms, :default, :boolean
  end
end
