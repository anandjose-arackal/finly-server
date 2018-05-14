class Budgets::Destroy < Budgets::Base
  attr_accessor :budget

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << 'User or params not passed.'
    end
    if params.blank?
      add_message :error, 'Budget not found'
    end
  end

  def init
    id = (params[:id] or params[:budget_id])
    self.budgets = Budgets::Index.(user, params).budgets.with_id(id)
  end

  def validate
    unless self.budgets.present?
      add_message :error, 'Nothing to delete'
      return
    end
  end

  def authorize
  end

  def process
    self.budgets.each do |budget|
      unless budget.destroy
        messages[:error] = budget.errors.full_messages
      end
    end
  end

  def post_process
    messages[:success] << 'Budget(s) deleted'
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(user, params, messages)
  end

end