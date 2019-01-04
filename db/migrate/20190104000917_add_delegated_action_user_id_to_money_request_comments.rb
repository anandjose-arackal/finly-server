class AddDelegatedActionUserIdToMoneyRequestComments < ActiveRecord::Migration
  def change
    add_column :money_request_comments, :delegated_action_user_id, :integer
  end
end
