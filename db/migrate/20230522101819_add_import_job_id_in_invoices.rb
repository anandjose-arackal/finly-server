class AddImportJobIdInInvoices < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :import_job_id, :string, { limit: 40, null: true }
    add_column :yes_bank_vendors, :import_job_id, :string, { limit: 40, null: true }
    add_column :purchase_orders, :import_job_id, :string, { limit: 40, null: true }
  end
end
