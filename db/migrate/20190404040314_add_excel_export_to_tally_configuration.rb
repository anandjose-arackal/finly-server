class AddExcelExportToTallyConfiguration < ActiveRecord::Migration[5.2]
  def change
    add_column :tally_configurations, :excel_export, :boolean, default: false
  end
end
