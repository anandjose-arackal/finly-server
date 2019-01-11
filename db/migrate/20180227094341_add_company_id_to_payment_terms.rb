class AddCompanyIdToPaymentTerms < ActiveRecord::Migration[4.2]
  def change
    add_column :payment_terms, :company_id, :integer, references: "Company", foreign_key: true, index: true
  end
end
