class AddLocationToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :location_id, :integer, references: "BranchLocation", foreign_key: true, index: true
    add_column :reports, :cost_center_id, :integer, references: "CostCenter", foreign_key: true, index: true
  end
end
