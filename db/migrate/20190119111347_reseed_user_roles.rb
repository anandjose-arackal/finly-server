class ReseedUserRoles < ActiveRecord::Migration
  def change
    UserRole.seed_data
  end
end
