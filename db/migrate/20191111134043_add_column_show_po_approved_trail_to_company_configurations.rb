class AddColumnShowPoApprovedTrailToCompanyConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_column :company_configurations, :show_po_approved_trail, :boolean, default: false
  end
end
