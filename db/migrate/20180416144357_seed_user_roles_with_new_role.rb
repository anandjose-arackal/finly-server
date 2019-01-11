class SeedUserRolesWithNewRole < ActiveRecord::Migration[4.2]
  def change
    UserRole.create(name: "travel_manager")
  end
end
