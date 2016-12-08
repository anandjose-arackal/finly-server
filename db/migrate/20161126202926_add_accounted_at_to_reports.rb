class AddAccountedAtToReports < ActiveRecord::Migration
  def change
    add_column :reports, :accounted_at, :date
  end
end
