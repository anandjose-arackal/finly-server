class AddRouteToExportResource < ActiveRecord::Migration[5.2]
  def change
    add_column :export_resources, :route, :string
  end
end
