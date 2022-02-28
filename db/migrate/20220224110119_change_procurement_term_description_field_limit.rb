class ChangeProcurementTermDescriptionFieldLimit < ActiveRecord::Migration[6.0]
  def change
    change_column :procurement_terms, :description, :longtext
  end
end
