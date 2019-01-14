class AddAccountedAtToReports < ActiveRecord::Migration[4.2]
  def change
    add_column :reports, :accounted_at, :date
  end
end
