class SeedUserRolesWithNewRole < ActiveRecord::Migration
  def change
    UserRole.create(name: "travel_manager")
  end
end
