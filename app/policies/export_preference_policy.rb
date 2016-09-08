class ExportPreferencePolicy < ApplicationPolicy

  def initialize(user, export_field)
    @user = user
    @export_field = export_field
  end

  def create?
    check_admin_view
  end

  def destroy?
    check_admin_view
  end

  def update?
    check_admin_view
  end
end