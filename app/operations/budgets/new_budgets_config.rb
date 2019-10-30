class Budgets::NewBudgetsConfig < Budgets::Base

  attr_accessor :root_budgets, :all_budgets

  def pre_validate

  end

  def process
    company_budgets = user.company.budgets
    
    # self.root_budgets = user.company.budgets.roots.reorder(end_date: :desc)
    self.root_budgets = company_budgets.roots.reorder(end_date: :desc)

    # we want to give FE all root, their children, and their grand children
    self.all_budgets = company_budgets.reorder(end_date: :desc)
  end

  def success
    params[:root_budgets] = self.root_budgets
    params[:all_budgets] = self.all_budgets
    Budgets::NewBudgetsConfig::BudgetsConfigPresenter.new(user, params, messages)
  end

  class Budgets::NewBudgetsConfig::BudgetsConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :root_budgets, :all_budgets

    def init
      self.root_budgets = params[:root_budgets]
      self.all_budgets = params[:all_budgets]
    end
  end
end
