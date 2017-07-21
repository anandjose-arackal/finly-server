class AddForeignKeyConstraintForStateIdInUserProfile < ActiveRecord::Migration
  def change
    add_foreign_key :user_profiles, :states
  end
end
