class AddCompanyToProcurementTerms < ActiveRecord::Migration
  def change
    add_reference :procurement_terms, :company, index: true, foreign_key: true
  end
end
