class AddModifiedByIdToReports < ActiveRecord::Migration[4.2]
  def change
    add_column :reports, :modified_by_id, :integer
  end
end
