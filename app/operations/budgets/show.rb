class Budgets::Show < Budgets::Base

  def pre_validate
  end

  def init
    id = (params[:id] or params[:budget_id])
    self.budget = Budgets::Index.(user, params).budgets.with_id(id).first rescue nil
  end

  def validate
    if self.budget.blank?
      add_message :error, 'Budget not found'
    end
  end

  def pre_process

  end

  def process

  end

  def success
    params[:budget] = self.budget
    Budgets::Show::ShowPresenter.new(user, params, messages)

  end

  class Budgets::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :budget, :budget_trail_items, :spent_amount


    def init
      self.budget = params[:budget]

      if budget.budgetable_type == 'User'
        op = ::BudgetsProcessor::Calculate::User.(user, {budget: budget, get_items: true})
      elsif budget.budgetable_type == 'Category'
        op = ::BudgetsProcessor::Calculate::Category.(user, {budget: budget, get_items: true})
      elsif budget.budgetable_type == 'YesBankVendor'
        op = ::BudgetsProcessor::Calculate::YesBankVendor.(user, {budget: budget, get_items: true})
      elsif budget.budgetable_type == 'FieldDropDownItem'
        op = ::BudgetsProcessor::Calculate::FieldDropDownItem.(user, {budget: budget, get_items: true})
      end
      self.spent_amount = op.result[:spent_amount]
      self.budget_trail_items = op.result[:budget_trail_items] rescue []
    end
  end

end