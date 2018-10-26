class AddUniqueTokenToSsoKeys < ActiveRecord::Migration
  def change
    add_column :sso_keys, :token, :string
  end
end
