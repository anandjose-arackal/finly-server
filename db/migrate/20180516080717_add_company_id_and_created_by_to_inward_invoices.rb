class AddCompanyIdAndCreatedByToInwardInvoices < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :company_id, :integer, references: "Company", foreign_key: true, index: true
    add_column :invoices, :created_by_user_id, :integer, references: "User", foreign_key: true, index: true
  end
end
