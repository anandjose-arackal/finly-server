class AddMobileVerifiedToUserProfile < ActiveRecord::Migration
  def change
    add_column :user_profiles, :mobile_verified, :boolean, default: true, null: false
  end
end
