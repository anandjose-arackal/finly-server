# action to update an expense.
# params:
# expense_id, or id : the id of the expense that us going to be edited.
#

class Expense::Manual::Update < Expense::Manual::Base
  attr_accessor :updated_expense_params

  def pre_validate
    if params.blank? or user.blank?
      errors << "Parameters or user not present."
      return false
    end
    if params[:expense_id].nil? and params[:id].blank?
      errors << "Expense ID missing!"
      return false
    end
    if params[:expense][:amount].to_i < 0
      errors << "Amount can't be negative."
      return false
    end
  end

  def init
    super
    # setting up the expense params for updation
    self.updated_expense_params = manual_expense_params
    if expense
      if self.updated_expense_params[:amount_attributes].present? and self.updated_expense_params[:amount_attributes][:value].present? and
          expense.amount_id.present?
        self.updated_expense_params[:amount_attributes][:id] = expense.amount.id
      end
      if self.updated_expense_params[:manual_expense_attributes].present? and self.expense.manual_expense.id.present?
        self.updated_expense_params[:manual_expense_attributes][:id] = expense.manual_expense.id if expense
      end
      if expense.receipts.present? and updated_expense_params[:receipts_attributes].present?
        self.updated_expense_params[:receipts_attributes][0][:id] = expense.receipts.first.id
      end
    end
  end

  def authorize
    unless expense
      raise_unauthorized_exception
    end
    unless expense and expense.user_id == user.id
      raise_unauthorized_exception
    end
  end

  def process
    unless expense.update(updated_expense_params)
      errors << self.expense.errors.full_messages
      return false
    end
    true
  end

  def post_process
    # add comment in report if expense is added within report

    # send mailer indicating updation of expense
  end

end