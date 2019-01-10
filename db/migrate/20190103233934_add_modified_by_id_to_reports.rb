class AddModifiedByIdToReports < ActiveRecord::Migration
  def change
    add_column :reports, :modified_by_id, :integer
  end
end
