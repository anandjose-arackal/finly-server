class Masters::ExportTemplates::Policy < ApplicationPolicy
  def show?
    true
  end

  def create?
    true
  end

  def update?
    if @record.created_by.present?
      @record.created_by == @user
    else
      @user.admin?
    end
  end

  def default?
    true
  end
end
