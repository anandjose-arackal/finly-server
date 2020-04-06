class Budgets::SubBudgets < Budgets::Base

  def pre_validate
    if params[:id].blank?
      add_message :error, "Budget details not sent."
      return
    end
  end

  def init
    id = (params[:id] or params[:budget_id])
    params[:include_children] = true # this is so that children are included in the show API
    self.budget = Budgets::Index.(user, params).budgets.with_id(id).first rescue nil
  end

  def validate
    # Validate if record is present
    return if record_not_present
    # Validate if user is associated with the budget
    validate_association
  end

  def pre_process

  end

  def process

  end

  def success
    params[:budget] = self.budget
    Budgets::SubBudgets::ShowPresenter.new(user, params, messages)
  end

  class Budgets::SubBudgets::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :budget

    # has_scope :filter_date, using: [:from, :to], type: :hash
    has_scope :filter_ids
    has_scope :filter_month
    has_scope :filter_year
    has_scope :filter_search

    def init
      self.budget = params[:budget]
      self.budget = apply_scopes(self.budget, params)
    end
  end

  private

  def validate_presence
    if self.budget.blank? || (self.budget.company_id != user.company_id)
      add_message :error, 'Budget not found'
      return false
    end
    true
  end

  def record_not_present
    !validate_presence
  end

  def validate_association
    return if budget.validate_if_admin?(user)
    return if budget.validate_if_owner?(user)
    return if budget.validate_if_manager?(user)
    raise_unauthorized_exception
  end

end