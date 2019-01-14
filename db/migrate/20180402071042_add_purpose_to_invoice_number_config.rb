class AddPurposeToInvoiceNumberConfig < ActiveRecord::Migration[4.2]
  def change
    add_reference :invoice_number_configs, :purpose, index: true, foreign_key: true
  end
end
