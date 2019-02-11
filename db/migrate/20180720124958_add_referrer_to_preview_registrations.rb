class AddReferrerToPreviewRegistrations < ActiveRecord::Migration[4.2]
  def change
    add_column :preview_registrations, :referrer, :string
  end
end
