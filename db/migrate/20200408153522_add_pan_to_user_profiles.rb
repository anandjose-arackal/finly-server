class AddPanToUserProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :user_profiles, :pan, :string
    add_index :user_profiles, :pan
  end
end
