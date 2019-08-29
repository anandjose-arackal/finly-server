require "#{Rails.root}/app/policies/application_policy"
class EventManager::Workflow::Policy < ApplicationPolicy

  class EventManager::Workflow::Policy::Scope < ApplicationPolicy::Scope

    def personal
      scope.where(user: @user)
    end

  end

  def create?
    true
    # @user.permissions.expenses.create?
  end

  def update?
    @record.user == @user
  end

  def destroy?
    @record.user == @user # and @model.status_id < 2
  end

end