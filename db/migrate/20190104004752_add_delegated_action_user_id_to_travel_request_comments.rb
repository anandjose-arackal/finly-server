class AddDelegatedActionUserIdToTravelRequestComments < ActiveRecord::Migration
  def change
    add_column :travel_request_comments, :delegated_action_user_id, :integer
  end
end
