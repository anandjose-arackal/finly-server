class Budgets::Show < Budgets::Base

  def pre_validate
  end

  def init
    id = (params[:id] or params[:budget_id])
    params[:include_children] = true # this is so that children are included in the show API
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
    attr_accessor :budget, :budget_trail_items, :spent_amount, :spent_entities


    def init
      self.budget = params[:budget]
      processor_instance = BudgetsCalculator::Calculate::BudgetsProcessor.new(self.budget)
      self.spent_amount = processor_instance.spent_amount
      self.spent_entities = processor_instance.spent_entities
    end
  end

end