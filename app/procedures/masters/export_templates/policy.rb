class Masters::ExportTemplates::Policy < ApplicationPolicy
  def show?
    true
  end

  def create?
    true
  end

  def update?
    @record.created_by == @user
  end
end
