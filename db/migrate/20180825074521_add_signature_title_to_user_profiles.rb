class AddSignatureTitleToUserProfiles < ActiveRecord::Migration
  def change
    add_column :user_profiles, :signature_title, :string
  end
end
