class AddTemplateConfigToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :is_deleted, :boolean, index: true, default: false
  end
end
