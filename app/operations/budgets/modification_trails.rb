class Budgets::ModificationTrails < Budgets::Base

  attr_accessor :budget, :trails

  class Budgets::ModificationTrails::TrailsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :trails

    def init
      self.trails = params[:trails]
    end
  end

  def pre_validate

  end

  def init
    id = params[:id] || params[:budget_id]
    self.budget = user.company.budgets.find_by(id: id)
  end

  def validate
    if self.budget.blank?
      add_message :error, "Budget not found"
    end
  end

  def process
    self.trails = self.budget.budget_modification_trails
  end

  def success
    params[:trails] = self.trails
    Budgets::ModificationTrails::TrailsPresenter.new(user, params, messages)
  end
end