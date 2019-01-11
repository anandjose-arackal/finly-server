class AddCompletedFlagToCallbackTrack < ActiveRecord::Migration[4.2]
  def change
    add_column :callback_tracks,:success, :boolean
  end
end
