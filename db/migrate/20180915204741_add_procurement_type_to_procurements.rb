class AddProcurementTypeToProcurements < ActiveRecord::Migration
  def change
    add_column :procurements, :procurement_type, :string
  end
end
