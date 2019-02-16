# action to add exisitng expenses to a report.
# params:
# report_id: id of the report to which expenses need to be added
# expense_ids : array of ids of expenses that need to be added to the report.

class Reports::Expenses::Add < Reports::Base

  attr_accessor :expenses, :auto_submit

  def authorized_user_types
    return nil if params.present? and params[:auto_submit]
    [:employee]
  end

  def pre_validate
    if params.blank?
      add_message :error, 'Error loading expenses'
      return
    end
    if user.blank? and not params[:auto_submit]
      add_message :error, 'User not found'
      return
    end
    if params[:expense_ids].blank? and params[:expense_id].blank? and params[:expenses].blank?
      add_message :error, 'No expenses to add'
    end
  end

  def init
    self.report= params[:report]
    self.auto_submit = params[:auto_submit]
    id = (params[:report_id] or params[:id])
    return if self.report.blank? and id.blank?
    if self.report.blank? and id.present?
      reports_presenter = Reports::Index.(self.user, self.params)
      unless reports_presenter.success?
        self.messages = reports_presenter.errors
        return false
      end
      self.report = reports_presenter.reports.with_id(id).first rescue nil
    end
    self.expenses = params[:expenses]
    if params[:expenses].blank? and user.present?
      ids = (params[:expense_ids] or params[:expense_id])
      # Split if IDS are sent as one comma delimited string
      ids= ids.split(',')
      self.expenses = user.expenses.with_id(ids)
    end
    self.expenses = self.expenses&.includes_export
  end

  def authorize
    unless report
      add_message :error, 'Report not found'
      return false
    end

    # checking if the expense ids correspond to actual expenses
    unless expenses
      add_message :error, 'No expenses found to add to the report'
      return false
    end

    unless auto_submit or (user.present? and report.user_id == user.id)
      add_message :error, 'You cannot add expenses to this report'
    end
  end

  def validate
    # checking state of the report
    unless report.open? or report.retracted? or report.rejected?
      add_message :error, 'Cannot add expenses to report unless report is in open or retracted state'
    end

    expenses.each do |expense|
      if expense.personal
        add_message :error, "Personal expenses cannot be added to a report"
        return false
      end
    end
  end

  def pre_process
    # mark the respective expenses that are from cash on hand as blocked
    # so that we can raise the rest as violations inside a report
    expenses.spent_from_cash_on_hand.each do |expense|
      if expense.cash_on_hand_blocked
        next
      end
      pocket = expense.spent_from
      if pocket.present? && pocket.cash_pocket?
        cash_pocket_adapter = AccountManager::CashPockets::CashPocketsAdapter.new(pocket)
        amount = expense.calculate_amount_value(report.policy)
        if cash_pocket_adapter.balance(display_balance: true) >= amount
          expense.update(cash_on_hand_blocked: true)
        end
      elsif pocket.present? && pocket.credit_card_pocket?
        expense.update(cash_on_hand_blocked: true)
      end
    end
  end

  def process
    expenses.update_all(report_id: report.id, expense_status_id: ExpenseStatus.unsubmitted_id, manager_memo: nil, rejecting_manager_id: nil)
    expenses.each do |expense|
      calculate_amounts(expense) # method that calculates the amount for all distance, time and Per Diem expenses
      # unless expense.update_attributes(report_id: report.id, expense_status_id: ExpenseStatus.unsubmitted_id, manager_memo: nil, rejecting_manager: nil)
      #   messages[:error] = expense.errors.full_messages
      # end
    end
  end

  def post_process
    if success?
      if report.retracted?
        expenses.each do |expense|
          comment = report.comments.build user: user, report_comment_action_id: ReportCommentAction.id_for(:expense_add), expense_id: expense.id
          comment.save
        end
      end
      add_message :success, 'Expenses added'
    end
  end

  private

  def calculate_amounts(expense)
    # expenses.each do |expense|
    if expense.card_expense? || expense.manual_expense?
      return
    else
      amount = expense.amount
      if amount.nil?
        amount_params = {value: expense.calculate_amount_value(report.policy), currency_id: Currency.first.id}
        amount = Amount.create(amount_params)
      else
        amount.update(value: expense.calculate_amount_value(report.policy))
      end
      expense.update_attributes(amount_id: amount.id)
      expense.update_other_currencies unless expense.date == DateUtils.local_date
    end
    # end
  end
end