class Budgets::NewBudgetsConfig < Budgets::Base

  attr_accessor :root_budgets

  def pre_validate

  end

  def process
    self.root_budgets = user.company.budgets.roots.reorder(end_date: :desc)
  end

  def success
    params[:root_budgets] = self.root_budgets
    Budgets::NewBudgetsConfig::BudgetsConfigPresenter.new(user, params, messages)
  end

  class Budgets::NewBudgetsConfig::BudgetsConfigPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :root_budgets

    def init
      self.root_budgets = params[:root_budgets]
    end
  end
end