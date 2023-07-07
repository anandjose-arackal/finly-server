class Docs::ExpenseManagement::Budgets::Resolver < Resolver::API

  entity Budget

  def load(params)
    budgets = nil
    if user.admin?(:em) || user.is_budget_manager?
      budgets = Budget.where(company_id: user.company_id)
    end

    budgets
  end

end
