class AnalyticsDashboard::Policy < ApplicationPolicy

  def show?
    user.admin? and record and (record.created_by_id == user.id or record.is_system_dashboard)
  end

  def create?
    user.admin?
  end

  def update?
    show?
  end

  def destroy?
    show?
  end

end