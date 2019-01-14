class AddTemplateConfigToInvoices < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :is_deleted, :boolean, index: true, default: false
  end
end
