class MakeTravelRequestsSoftDeletable < ActiveRecord::Migration[4.2]
  def change
    add_column :travel_requests, :is_deleted, :boolean, default: false
  end
end
