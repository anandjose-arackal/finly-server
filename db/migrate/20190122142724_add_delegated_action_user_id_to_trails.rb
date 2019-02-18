class AddDelegatedActionUserIdToTrails < ActiveRecord::Migration[5.2]
  def change
    add_column :trails, :delegated_action_user_id, :integer
  end
end
