class AddStatusToDoorkeeperToken < ActiveRecord::Migration[5.2]
  def change
    add_column :oauth_access_tokens, :status_id, :integer, foreign_key: true, index: true, references: :oauth_access_tokens, default: 1
    add_column :oauth_access_tokens, :message, :text
    Doorkeeper::AccessToken.update_all(status_id: 1)
  end
end
