class Documents::Invoices::Policy < ApplicationPolicy

  class Documents::Invoices::Policy::Scope < ApplicationPolicy::Scope

    def resolve
      scope.where(created_by_user_id: @user.id)
    end

  end

  def create?
    true
  end

end