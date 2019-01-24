class ReseedUserRoles < ActiveRecord::Migration[4.2]
  def change
    UserRole.seed_data
  end
end
