class AddInvoiceNumberConfigTypeToInvoiceNumberConfig < ActiveRecord::Migration[4.2]
  def change
    add_reference :invoice_number_configs, :invoice_number_config_type, index: true, foreign_key: true
  end
end
