class AddForeignKeyConstraintForStateIdInUserProfile < ActiveRecord::Migration[4.2]
  def change
    add_foreign_key :user_profiles, :states
  end
end
