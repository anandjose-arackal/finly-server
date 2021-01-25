class AddResolverToExportResource < ActiveRecord::Migration[6.0]
  def change
    add_column :export_resources, :resolver, :string
  end
end
