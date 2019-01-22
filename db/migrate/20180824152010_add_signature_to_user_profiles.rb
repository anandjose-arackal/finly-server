class AddSignatureToUserProfiles < ActiveRecord::Migration[4.2]
  def change
    add_attachment :user_profiles, :signature
  end
end
