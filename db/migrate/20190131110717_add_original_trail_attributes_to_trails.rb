class AddOriginalTrailAttributesToTrails < ActiveRecord::Migration[5.2]
  def change
    add_column :trails, :original_track_type, :string, polymorphic: true
    add_column :trails, :original_track_id, :integer, polymorphic: true
  end
end
