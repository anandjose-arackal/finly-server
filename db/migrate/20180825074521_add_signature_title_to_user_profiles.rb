class AddSignatureTitleToUserProfiles < ActiveRecord::Migration[4.2]
  def change
    add_column :user_profiles, :signature_title, :string
  end
end
