require "#{Rails.root}/app/policies/application_policy"
class TaskManager::Workflows::Policy < ApplicationPolicy

  class TaskManager::Workflows::Policy::Scope < Resolver::API

    def load(user, params)
      scope.where(user: user)
    end

  end

  def create?
    true
    # @user.permissions.expenses.create?
  end

  def show?
    true
  end

  def update?
    @record.user == @user
  end

  def destroy?
    @record.user == @user # and @model.status_id < 2
  end

end