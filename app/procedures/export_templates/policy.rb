require "#{Rails.root}/app/policies/application_policy"
class ExportTemplates::Policy < ApplicationPolicy

  class ExportTemplates::Policy::Resolver < ApplicationPolicy::Resolver

    def personal
      scope.where(created_by_user: @user)
    end

    def team
      scope
    end

    def admin
      scope
    end

  end

  def create?
    true
    # @user.permissions.expenses.create?
  end

  def update?
    @record.created_by_user == @user
  end

  def destroy?
    @record.created_by_user == @user # and @model.status_id < 2
  end

end