class ChangeUserSessionCityEncodingToUtf8 < ActiveRecord::Migration[6.0]
  def change
    change_column :user_sessions, :city, "VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_bin"

  end
end
