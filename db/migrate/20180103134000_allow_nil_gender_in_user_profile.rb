class AllowNilGenderInUserProfile < ActiveRecord::Migration[4.2]
  def change
    change_column_null :user_profiles, :gender, true
  end
end
