class AddDelegatedActionUserIdToMoneyRequestTracks < ActiveRecord::Migration[4.2]
  def change
    add_column :money_request_tracks, :delegated_action_user_id, :integer
  end
end
