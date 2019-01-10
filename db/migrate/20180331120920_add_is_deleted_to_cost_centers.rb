class AddIsDeletedToCostCenters < ActiveRecord::Migration[4.2]
  def change
    add_column :cost_centers, :is_deleted, :boolean
  end
end
