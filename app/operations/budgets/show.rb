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
    attr_accessor :budget

    def init
      self.budget = params[:budget]
    end
  end

end