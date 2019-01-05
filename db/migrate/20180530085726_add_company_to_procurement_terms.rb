class AddCompanyToProcurementTerms < ActiveRecord::Migration[4.2]
  def change
    add_reference :procurement_terms, :company, index: true, foreign_key: true
  end
end
