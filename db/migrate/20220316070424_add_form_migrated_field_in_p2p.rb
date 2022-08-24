class AddFormMigratedFieldInP2p < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :form_migrated, :boolean
    add_column :purchase_orders, :form_migrated, :boolean
    add_column :purchase_requests, :form_migrated, :boolean
  end
end
