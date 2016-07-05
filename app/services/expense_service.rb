class ExpenseService < BaseService

  def initialize(current_user)
    super()
    @user = current_user
  end

  def user_expenses
    return nil unless @user
    @user.expenses.includes(:manual_expense)
  end

  def add_expense(params=nil)
    return if params.blank?
    expense_params = load_expense_params params
    expense = @user.expenses.build(expense_params)
    if expense.save
      return expense
    else
      errors << expense.errors.full_messages
      return false
    end
  end

  def remove_expense(id = nil)
    return if id.blank?
    expense = load_expense id
    if expense.destroy
      return true
    else
      errors << expense.errors.full_messages
      return false
    end
  end

  def update_expense(params=nil)
    return if params.blank?
    expense_params = load_expense_params params
    expense = load_expense expense_params[:id] || expense_params[:expense_id]
    unless expense
      return false
    end
    if expense.update(expense_params)
      expense.reload
      return expense
    else
      errors << expense.errors.full_messages
      return false
    end
  end

  def report_expenses

  end

  # accepts receipt and expense
  def add_receipt_to_expense(params = {}, expense_id = nil)
    return if params.blank? || expense_id.nil?
    receipt_params = load_receipt_params params
    expense = load_expense expense_id
    return unless expense
    # create the expense associated with the expense
    attach = expense.receipts.create(receipt_params)
    # associating the current user with the receipt
    attach.user = @user
    if attach.save
      return attach
    else
      errors << attach.errors.full_messages
      false
    end
  end

  def attach_receipt_to_expense(receipt_id, expense_id)
    return if receipt_id.blank? || expense_id.blank?
    receipt = @user.receipts.find_by(id: receipt_id)
    if receipt.parent
      errors << receipt.errors.add(:receipt, "is already added to another expense.")
      return false
    end
    expense = load_expense expense_id
    receipt.parent = expense
    if receipt.save
      return receipt
    else
      errors << receipt.errors.full_messages
      return false
    end
  end

  # will just remove the association between expense and receipt
  def detach_receipt_from_expense(receipt_id, expense_id)
    return if receipt_id.blank? || expense_id.blank?
    receipt = @user.receipts.find_by(id: receipt_id)
    if receipt.nil? || receipt.parent_id != expense_id
      errors << receipt.errors.add(:receipt, "does not belong to this expense.")
      return false
    end
    receipt.parent_id = receipt.parent_type = nil
    if receipt.save
      return receipt
    else
      errors << receipt.errors.full_messages
      return false
    end
  end

  def expense_from_receipt(params = nil, receipt_id = nil)
    return unless params || receipt_id
    expense_params = load_expense_params params
    expense = @user.expenses.build(expense_params)
    receipt = @user.receipts.find_by(id: receipt_id)
    if expense.save
      receipt.parent = expense
      if receipt.save
        return expense
      else
        errors << receipt.errors.full_messages
        return false
      end
    else
      errors << expense.errors.full_messages
      false
    end
  end

  # todo - will come in report
  # def reject_expenses(id, memo=nil)
  #   return if id.blank?
  #   expense = load_expense id
  #   return if expense.blank?
  #   # making the expense unsubmitted with the memo
  #   if expense.update(manager_memo: memo, expense_status_id: 1)
  #     return true
  #   else
  #     errors << expense.errors.full_messages
  #   end
  #   false
  # end

  private

  def load_expense_params(params = {})
    expense_params = params[:expense].except(:amount, :currency_id)
    expense_params[:amount_attributes] = {value: params[:expense][:amount], currency_id: params[:expense][:currency_id]}
    if params[:expense][:merchant].present?
      expense_params[:manual_expense_attributes] = {merchant: params[:expense][:merchant]}
      expense_params.delete(:merchant)

    # other conditions based on type of expense can go here
    end
    expense_params
  end

  def load_receipt_params(params)
    receipt_params = params[:receipt].slice(:image)
  end

  def load_expense(id)
    @user.expenses.find_by(id: id)
  end
end