class AddIsTemplateToPurchaseOrder < ActiveRecord::Migration[4.2]
  def change
    add_column :purchase_orders, :is_template, :boolean, index: true, default: false
    add_column :purchase_orders, :template_name, :string, index: true

    add_column :invoices, :is_template, :boolean, index: true, default: false
    add_column :invoices, :template_name, :string, index: true
  end
end
