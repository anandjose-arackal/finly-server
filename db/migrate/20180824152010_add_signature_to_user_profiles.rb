class AddSignatureToUserProfiles < ActiveRecord::Migration
  def change
    add_attachment :user_profiles, :signature
  end
end
