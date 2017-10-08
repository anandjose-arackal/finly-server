# action to destroy a particular expense.
# params:
# expense_id, or id : id of the expense that is to be deleted.

class Expense::Destroy < Expense::Base
  attr_accessor :expenses

  def pre_validate
    if params.blank? or user.blank?
      add_message :error, 'Parameters or user not present'
    end
    if params[:expense_id].blank? and params[:id].blank?
      add_message :error, 'Expense not found'
    end
  end

  def init
    self.expenses = user.expenses.with_id(params[:expense_id] || params[:id])
  end

  def authorize
    non_owner_expenses = self.expenses&.pluck(:user_id) - [user.id]
    if non_owner_expenses.present?
      add_message :error, 'Only expense owners can delete expenses'
      raise_unauthorized_exception
    end
  end

  def validate
    unless expenses.present?
      add_message :error, 'Cannot find expense to delete'
      return
    end

    self.expenses.each do |expense|
      if expense.expense_type_id == ExpenseType.card_expense_id
        add_message :error, 'Card expenses cannot be deleted'
      end

      if expense.report.present?
        unless expense.report.editable?
          add_message :error, 'Report is not editable at this stage to delete the selected expense'
          return
        end
      end
    end
  end

  def process
    self.expenses.each do |expense|
      # todo - jugaad for iOS - Remove expenses from report when destroy is called if expense is in a report
      if expense.report_id.present?
        unless expense.update_attributes report_id: nil, expense_status_id: ExpenseStatus.unreported_id
          add_message :error, expense.errors.full_messages
          return false
        end
      else
        unless expense.destroy
          add_message :error, expense.errors.full_messages
          return false
        end
      end
    end
  end

  def post_process
    # # if it's a manual expense that was marked against cash on hand and isn't part of a report, add the respective amount to cash on hand
    # if expense.from_cash_on_hand && expense.manual? && !expense.report_id.present?
    #   payment_request = PaymentRequest.(user, nil, "CashOnHand", :credit, :advance_against_cash_on_hand_expense_deletion)
    #   payment_request.add_payment_item(PaymentRequest::PaymentItem.(user, user.cash_on_hand, expense.amount_value))
    #   op = AccountManager::Payments::PaymentProcessor.(user, payment_request: payment_request)
    # end

    add_message :success, 'Expense deleted'
  end

  def success
    BaseOperation::BasePresenter::SuccessPresenter.new(user, params, messages)
  end

end
