class SetAdminUserRoles < ActiveRecord::Migration[4.2]
  def change
    if KycStatus.id_for(:rejected).present?
      KycStatus.find_by(name: 'error')&.update(name: 'rejected')
    end

    if Company.count > 0
      AdminUserRole.destroy_all
      AdminUserRole.seed_data
    end
  end
end
