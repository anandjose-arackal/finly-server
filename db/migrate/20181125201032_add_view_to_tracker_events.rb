class AddViewToTrackerEvents < ActiveRecord::Migration
  def change
    add_column :tracker_events, :view, :string, index: true
  end
end
