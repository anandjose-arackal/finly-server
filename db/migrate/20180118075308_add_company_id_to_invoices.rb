class AddCompanyIdToInvoices < ActiveRecord::Migration
  def change
    add_column :outward_invoices, :company_id, :integer, references: "Company", foreign_key: true, index: true
  end
end