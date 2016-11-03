# updating the expense from user's expenses view.
# The only editable fields are: editable_merchant, note, category_id, and receipts

class Expense::ExCard::Update < Expense::ExCard::Base
  attr_accessor :updated_expense_params

  def pre_validate
    if user.blank? or params.blank?
      messages[:error] << "Parameters not present."
    end
    if params[:expense_id].blank? and params[:id].blank?
      messages[:error] << "Expense ID missing!"
    end
  end


  def init
    id = (params[:expense_id] or params[:id])
    self.expense = user.expenses.find_by(id: id)
    self.updated_expense_params = update_card_expense_params
    if updated_expense_params[:receipts_attributes] == [nil]
      updated_expense_params.delete(:receipts_attributes)
      # if the receipts attributes is passed as [nil], the receipt attached to this expense gets disassociated
      # todo - check of the api fails because of this
      receipt = expense.receipts.first
      if receipt
        receipt.parent = nil
        receipt.save
      end
    end

    if expense.receipts.present? and updated_expense_params[:receipts_attributes].present?
      self.updated_expense_params[:receipts_attributes][0][:id] = expense.receipts.first.id
    end
  end


  def validate

  end


  def authorize
    unless expense
      raise_unauthorized_exception
    end
    unless expense.user_id == user.id
      raise_unauthorized_exception
    end
  end


  def process
    unless expense.update(updated_expense_params)
      messages[:error] = self.expense.errors.full_messages
      return false
    end
  end

  def success
    Expense::Base::Presenter.new(user, {expense: self.expense}, self.messages)
  end

  def post_process
    # send mailer or notification indicating updation of expense
  end

  private

end
