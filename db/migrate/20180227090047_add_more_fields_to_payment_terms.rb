class AddMoreFieldsToPaymentTerms < ActiveRecord::Migration
  def change
    add_column :payment_terms, :days_after, :integer
    add_column :payment_terms, :description, :text
  end
end
