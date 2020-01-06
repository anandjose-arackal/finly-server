class ChangeSsoColumnInTokens < ActiveRecord::Migration[5.2]
  def change
    rename_column :oauth_access_tokens, :sso_login, :authentication_type
    change_column :oauth_access_tokens, :authentication_type, :string, default: "password"
  end
end
