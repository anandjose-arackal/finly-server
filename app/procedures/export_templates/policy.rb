require "#{Rails.root}/app/policies/application_policy"
class ExportTemplates::Policy < ApplicationPolicy

  class ExportTemplates::Policy::Scope < Resolver::API

    def load(user, params)
      Success(scope.where(created_by_user: user))
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