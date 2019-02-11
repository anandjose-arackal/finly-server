class AddViewToTrackerEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :tracker_events, :view, :string, index: true
  end
end
