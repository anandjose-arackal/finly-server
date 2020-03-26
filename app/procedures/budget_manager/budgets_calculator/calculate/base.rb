class BudgetManager::BudgetsCalculator::Calculate::Base < BaseOperation
  attr_accessor :budget, :spent_amount, :budget_trail_items, :items_requested

  def init
    self.budget = params[:budget]
    self.spent_amount = 0

    if params[:get_items]
      self.items_requested = true
      self.budget_trail_items = []
    end
  end

  def process
  end

  def success
    params[:budget] = self.budget
    params[:spent_amount] = self.spent_amount
    if self.items_requested
      params[:budget_trail_items] = self.budget_trail_items
    end
    BudgetsProcessor::Calculate::Base::BasePresenter.new(user, params, messages)
  end

  class BudgetsProcessor::Calculate::Base::BasePresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :result, :budget

    def init
      self.budget = params[:budget]
      self.result = {
          budget: self.budget,
          budget_amount: self.budget.budget_amount.value,
          spent_amount: params[:spent_amount],
          associated_item: get_associated_item
      }

      if params[:get_items]
        budget_trail_items = params[:budget_trail_items]
        self.result[:budget_trail_items] = budget_trail_items.sort_by {|item| item[:date]}.reverse!
      end
    end

    def get_associated_item
      item = budget.budgetable_type.constantize.find_by(id: self.budget.budgetable_id)

      item_details = {
          type: self.budget.budgetable_type,
          id: item.id,
          name: item.name
      }
    end
  end
end