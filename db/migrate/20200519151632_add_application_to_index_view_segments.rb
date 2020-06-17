class AddApplicationToIndexViewSegments < ActiveRecord::Migration[5.2]
  def change
    add_column :index_view_segments, :application, :string, index: true
    IndexViewSegment.update_all(application: :vp)
  end
end
