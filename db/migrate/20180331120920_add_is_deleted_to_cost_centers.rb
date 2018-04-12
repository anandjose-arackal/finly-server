class AddIsDeletedToCostCenters < ActiveRecord::Migration
  def change
    add_column :cost_centers, :is_deleted, :boolean
  end
end
