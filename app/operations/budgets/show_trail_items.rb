# used to show data on documents which are consuming the current budget
# 
class Budgets::ShowTrailItems < Budgets::Base

  def pre_validate
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

    if params[:type].blank? or %w(expenses payments purchase_order_items invoice_items).exclude? params[:type]
      add_message :error, "Associated document for the budget not specified"
      return
    end
  end

  def pre_process

  end

  def process
  end

  def success
    params[:budget] = self.budget
    Budgets::Show::ShowTrailItemsPresenter.new(user, params, messages)
  end

  class Budgets::Show::ShowTrailItemsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :budget, :budget_trail_items, :spent_amount, :spent_entities,
                  :paginated_expenses, :paginated_payments, :paginated_purchase_order_items, :paginated_invoice_items,
                  :paginated_entities


    def init
      self.budget = params[:budget]
      processor_instance = BudgetManager::BudgetsCalculator::Calculate::BudgetsProcessor.new(self.budget)
      self.spent_entities = processor_instance.consumed_entities
      per_page = params[:per_page] || 30
      page = params[:page] || 1

      case params[:type]
      when 'expenses'
        self.paginated_entities = self.spent_entities[0].paginate(per_page: per_page, page: page)
      when 'payments'
        self.paginated_entities = self.spent_entities[1].paginate(per_page: per_page, page: page)
      when 'purchase_order_items'
        self.paginated_entities = self.spent_entities[2].paginate(per_page: per_page, page: page)
      when 'invoice_items'
        self.paginated_entities = self.spent_entities[3].paginate(per_page: per_page, page: page)
      end
    end
  end

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