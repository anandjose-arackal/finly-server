class AddCompletedFlagToCallbackTrack < ActiveRecord::Migration
  def change
    add_column :callback_tracks,:success, :boolean
  end
end
