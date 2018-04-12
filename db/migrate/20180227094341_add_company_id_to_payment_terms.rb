class AddCompanyIdToPaymentTerms < ActiveRecord::Migration
  def change
    add_column :payment_terms, :company_id, :integer, references: "Company", foreign_key: true, index: true
  end
end
