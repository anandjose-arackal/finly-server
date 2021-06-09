class AddCurrencyToDifferentDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :purchase_requests, :base_currency_id, :integer
    add_column :purchase_requests, :reporting_currency_id, :integer

    add_column :purchase_orders, :base_currency_id, :integer
    add_column :purchase_orders, :reporting_currency_id, :integer

    add_column :payments, :base_currency_id, :integer
    add_column :payments, :reporting_currency_id, :integer
    
    add_column :credit_notes, :base_currency_id, :integer
    add_column :credit_notes, :reporting_currency_id, :integer
    
    add_column :payment_agreements, :base_currency_id, :integer
    add_column :payment_agreements, :reporting_currency_id, :integer
        
    add_column :inward_documents, :base_currency_id, :integer
    add_column :inward_documents, :reporting_currency_id, :integer

    add_column :bbps_bills, :base_currency_id, :integer
    add_column :bbps_bills, :reporting_currency_id, :integer
  end
end
