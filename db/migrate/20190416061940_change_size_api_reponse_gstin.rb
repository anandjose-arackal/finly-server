class ChangeSizeApiReponseGstin < ActiveRecord::Migration[5.2]
  def up
    change_column :gstins, :api_response, :text, :limit => 16777215
  end

  def down
    change_column :gstins, :api_response, :text, :limit => 65535
  end
end
