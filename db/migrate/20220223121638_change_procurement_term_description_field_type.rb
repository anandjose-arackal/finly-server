class ChangeProcurementTermDescriptionFieldType < ActiveRecord::Migration[6.0]
  def change
    change_column :procurement_terms, :description, :text, length: 700000
  end
end
