class Documents::Invoices::Policy < ApplicationPolicy

  class Documents::Invoices::Policy::Resolver < ApplicationPolicy::Resolver

    def resolve(filters={})
      scope.where(created_by_user_id: @user.id).ransack(filters).result(distinct: true)
    end

  end

  def create?
    true
  end

end