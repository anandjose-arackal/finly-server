require "#{Rails.root}/app/policies/application_policy"
class EventManager::Workflows::Policy < ApplicationPolicy

  class EventManager::Workflows::Policy::Scope < ApplicationPolicy::Scope

    def personal
      scope.where(user: @user)
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