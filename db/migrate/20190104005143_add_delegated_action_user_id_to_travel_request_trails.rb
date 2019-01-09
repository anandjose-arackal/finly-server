class AddDelegatedActionUserIdToTravelRequestTrails < ActiveRecord::Migration
  def change
    add_column :travel_request_trails, :delegated_action_user_id, :integer
  end
end
