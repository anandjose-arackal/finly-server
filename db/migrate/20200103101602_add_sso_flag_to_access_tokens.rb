class AddSsoFlagToAccessTokens < ActiveRecord::Migration[5.2]
  def change
    add_column :oauth_access_tokens, :sso_login, :boolean, default: false
  end
end
