class AddIndexToReports < ActiveRecord::Migration[4.2]
  def change
    add_index :reports, :name
    add_index :money_requests, :name
  end
end
