class Macros::Jobs::Policy < ApplicationPolicy

  def create?
    return false unless record.company_id == user.company_id
    permissions = record.permissions
    # Permissions are not defined, scope it only to 'admin'
    permissions = [:admin] if permissions.blank?
    return false unless user.has_permission?(permissions)

    true
  end

end