class AddProcurementTypeToProcurements < ActiveRecord::Migration[4.2]
  def change
    add_column :procurements, :procurement_type, :string
  end
end
