class AddDefaultToProcurementTerms < ActiveRecord::Migration[5.2]
  def change
    add_column :procurement_terms, :default, :boolean, default: false
  end
end
