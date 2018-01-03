class AllowNilGenderInUserProfile < ActiveRecord::Migration
  def change
    change_column_null :user_profiles, :gender, true
  end
end
