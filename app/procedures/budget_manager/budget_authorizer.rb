class BudgetManager::BudgetAuthorizer

  def initialize(user, budget)
    @user = user
    @budget = budget
  end

  def create?
    @user.is_budget_manager? || @user.vendor_payments_admin? || @result.company_admin?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  def index?
    create?
  end

  def show?
    create?
  end


end
