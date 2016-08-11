class ExpenseService < BaseService
  attr_accessor :user, :params

  def initialize(current_user, params = {})
    super()
    @user = current_user
    self.params = params
  end

  def expenses(role_id)
    return nil unless @user
    case role_id
      when UserRole.admin_id
        user_ids = UserTeamService.new(@user).team(UserRole.admin_id, self.params).pluck(:id)
        return Expense.where(user_id: user_ids).submitted.includes(:manual_expense)
      when UserRole.finance_manager_id
        user_ids = UserTeamService.new(@user).team(UserRole.finance_manager_id, self.params).pluck(:id)
        return Expense.where(user_id: user_ids).submitted.includes(:manual_expense)
      when UserRole.manager_id
        user_ids = UserTeamService.new(@user).team(UserRole.manager_id, self.params).pluck(:id)
        return Expense.where(user_id: user_ids).submitted.includes(:manual_expense)
      when UserRole.employee_id
        return @user.expenses.unreported.includes(:manual_expense)
    end
  end

  def add_expense(params=nil)
    return if params.blank?
    expense_params = load_expense_params params
    expense = @user.expenses.build(expense_params)
    if expense.save
      ReportService.new(user: @user, report: expense.report).expense_created_in_report(expense) if expense.report_id.present? and @user.present?
      return expense
    else
      errors << expense.errors.full_messages
      return false
    end
  end

  def remove_expense(id = nil)
    return if id.blank?
    expense = load_expense id
    unless expense
      errors << 'Expense does not belong to user.'
    end
    if expense.destroy
      return true
    else
      errors << expense.errors.full_messages
      return false
    end
  end

  def update_expense(params=nil, expense_id)
    return true if params.blank?
    expense_params = load_expense_params params
    expense = load_expense expense_id
    unless expense
      errors << 'Expense does not belong to user.'
      return false
    end
    # adding receipt, manual expense and amount ids so that they get updated and not recreated
    manual_expense_id = expense.manual_expense.id
    amount_id = expense.amount.id
    expense_params[:manual_expense_attributes][:id] = manual_expense_id
    expense_params[:amount_attributes][:id] = amount_id

    if expense.receipts.present? and params[:receipt].present?
      receipt_id = expense.receipts.first.id
      expense_params[:receipts_attributes][0][:id] = receipt_id
    end

    old_expense = expense # stub to keep track of what's changed
    if expense.update_attributes(expense_params)
      # Callback to create comments in report when an expense is edited
      if expense.report_id.present? and @user.present?
        ReportService.new(user: user, report: expense.report).expense_updated_in_report(expense, old_expense)
      end
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

    # checking if the expense already has an associated receipt - if it does, detach that receipt, and add the new one
    if expense.receipts.present?
      detach_receipt_from_expense(expense.receipts.first.id, expense.id)
    end

    # build the expense associated with the expense
    attach = expense.receipts.build(receipt_params)
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
    return unless params && receipt_id
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


  private

  def load_expense_params(params = {})
    expense_params = params.except(:amount, :merchant, :currency_id, :receipt_id, :receipt)

    # for manual expenses only
    expense_params[:expense_type_id] = 1 if expense_params[:expense_type_id].nil?
    # i.e. it's an unreported expense if no report id is present, and unsubmitted if report id is present.
    expense_params[:expense_status_id] = 1 if expense_params[:expense_status_id].nil? && expense_params[:report_id].nil?
    expense_params[:expense_status_id] = 2 if expense_params[:report_id].present?

    expense_params
  end

  def load_receipt_params(params)
    receipt_params = params.slice(:image)
  end

  # if expense belongs to user, it returns the expense, otherwise false
  def load_expense(id)
    @user.expenses.find_by(id: id)
  end
end