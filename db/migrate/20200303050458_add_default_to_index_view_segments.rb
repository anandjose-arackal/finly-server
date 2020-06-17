class AddDefaultToIndexViewSegments < ActiveRecord::Migration[5.2]
  def change
    add_column :index_view_segments, :default, :boolean, index: true, default: false
  end
end
