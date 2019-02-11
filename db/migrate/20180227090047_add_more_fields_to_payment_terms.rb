class AddMoreFieldsToPaymentTerms < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_terms, :days_after, :integer
    add_column :payment_terms, :description, :text
  end
end
