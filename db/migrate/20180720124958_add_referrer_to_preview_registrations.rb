class AddReferrerToPreviewRegistrations < ActiveRecord::Migration
  def change
    add_column :preview_registrations, :referrer, :string
  end
end
