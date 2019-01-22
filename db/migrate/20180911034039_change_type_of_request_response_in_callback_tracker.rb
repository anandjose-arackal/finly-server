class ChangeTypeOfRequestResponseInCallbackTracker < ActiveRecord::Migration[4.2]
  def change
    change_column :callback_tracks, :request, :text
    change_column :callback_tracks, :response, :text, limit: 16.megabytes - 1
  end
end
