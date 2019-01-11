class AddUniqueTokenToSsoKeys < ActiveRecord::Migration[4.2]
  def change
    add_column :sso_keys, :token, :string
  end
end
