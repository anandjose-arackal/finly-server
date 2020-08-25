class AddIpToVersions < ActiveRecord::Migration[5.2]
  def change
    add_column :versions, :user_ip, :string
    add_column :versions, :user_agent,:string
  end
end
