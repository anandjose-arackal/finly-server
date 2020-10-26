class ChangeColumnResultInMapLocationSearch < ActiveRecord::Migration[6.0]
  def change
      change_column :map_location_searches, :result, "TEXT(65535) CHARACTER SET utf8 COLLATE utf8_bin"
  end
end
