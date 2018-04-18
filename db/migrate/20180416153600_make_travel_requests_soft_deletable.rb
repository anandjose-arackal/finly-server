class MakeTravelRequestsSoftDeletable < ActiveRecord::Migration
  def change
    add_column :travel_requests, :is_deleted, :boolean, default: false
  end
end
