class SeedUserRoleWithNewRoles < ActiveRecord::Migration[5.2]
  def change
    UserRole.seed_data
  end
end
