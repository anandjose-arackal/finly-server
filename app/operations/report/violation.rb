# action to retrieve the violations that are present in a report.
# params:
# report_id: id of the report that requires violations
# return a hash with each expense_id as key, and the value as a hash of the expense and budget violations
# format:
# warning_messages: { expense_id : {expense_warning: {receipt: *contains receipt warning*
#                                                     note: *contains note warning*
#                                                     disallow: *contains disallow warning*}
#                                   expense_blocking: {receipt: *contains receipt blocks*
#                                                     note: *contains note blocks*
#                                                     disallow: *contains disallow blocks*}
#                                   budget_warning: {*category name* : *category budget exceeded warning*
#                                                           ...
#                                                    total: *total budget exceeded warning*
#                                   budget_blocking: {*category name* : *category budget exceeded blocks*
#                                                           ...
#                                                    total: *total budget exceeded blocks* }
#                                   }
#
#                      ... (similarly for all expenses in the report)
#
#                   }

class Report::Violation < Report::Base
  include ActionView::Helpers::NumberHelper
  attr_accessor :no_policy, :warning_messages, :policy

  def authorized_user_types
    nil
  end

  def pre_validate
    if params.blank? or params[:report].blank?
      add_message :error, 'Report not found'
    end
  end

  def init
    self.warning_messages = {}
    self.report = params[:report]
    self.policy = report.versioned_policy
    report.expenses.each do |expense|
      self.warning_messages[expense.id] = {}
      self.warning_messages[expense.id]['expense_warning'] = []
      self.warning_messages[expense.id]['expense_blocking'] = []
      self.warning_messages[expense.id]['budget_warning'] = []
      self.warning_messages[expense.id]['budget_blocking'] = []
    end
  end

  def validate
    if self.report.blank? or not self.report.is_a?(Report)
      messages[:error] << 'Report not found'
    end
    unless policy
      self.no_policy = true
    end
  end

  def process
    unless no_policy
      report.expenses.each do |expense|
        policy.expense_rules.each do |rule|
          check_expense_rule rule, expense
        end
        policy.budget_rules.each do |rule|
          check_budget rule, expense
        end
      end
    end
    self.response = warning_messages
  end

  def success
    self.response
  end

  private
  def check_expense_rule_violation(expense, rule, manager = nil)
    message = ''
    if rule.amount_value
      if expense.amount_value >= rule.amount_value
        message += ' above ' + rule.amount_value.to_s
      else
        return false
      end
    end
    if rule.category_id
      if expense.category_id == rule.category_id
        message += ' and belonging to category ' + expense.category_name
      else
        return false
      end
    end
    if rule.days_after
      if manager
        time_elapsed = (expense.report.submitted_at - expense.date).to_i
      else
        time_elapsed = (DateUtils.local_date - expense.date).to_i
      end
      if time_elapsed > rule.days_after
        message += ' added after ' + rule.days_after.to_s + ' days'
      else
        return false
      end
    end

    message
  end

  # checks the passed expense against the passed rule
  def check_expense_rule(rule, expense, manager = nil)
    warning = 'Expenses'
    broken = false
    # first check if there's a violation with the common criteria
    message = check_expense_rule_violation(expense, rule, manager)
    # checking if the specific rule is actually broken
    case rule.expense_rule_type_id
      when 1
        if expense.receipts_count > 0
          message = false # i.e. the rule is not broken because there is a receipt
        end
      when 2
        if expense.note && !expense.note.blank?
          message = false # i.e. the rule is not broken because there is a note
        end
      else
        # do nothing
    end
    if message
      warning += message
      broken = true
    end
    warning += ' require a receipt' if rule.expense_rule_type_id == 1
    warning += ' require a note' if rule.expense_rule_type_id == 2
    warning += ' are not allowed' if rule.expense_rule_type_id == 3
    rule_name = nil
    # initializing the rule name
    case rule.expense_rule_type_id
      when 1
        rule_name = 'receipt'
      when 2
        rule_name = 'note'
      when 3
        rule_name = 'disallow'
      else
        # do nothing
    end

    if broken
      if rule.type == 'Warning'
        self.warning_messages[expense.id]['expense_warning'] << {type: rule_name, message: warning}
      elsif rule.type == 'Blocking'
        self.warning_messages[expense.id]['expense_blocking'] << {type: rule_name, message: warning}
      end
    end
  end

  def budget_violation?(expense, rule, start_date, end_date, category = nil)
    user = expense.user
    report = expense.report
    total_expenses = 0
    # all user reports with the associated budget
    user.reports.where(report_status_id: [ReportStatus.id_for(:approved), ReportStatus.id_for(:settled), ReportStatus.id_for(:settlement_confirmed), ReportStatus.id_for(:closed)]).where(policy_id: rule.policy_id).where.not(id: report.id).each do |budget_report|
      if category
        total_expenses += number_with_precision(budget_report.expenses.where('date >= ? && date <= ?', start_date, end_date).where(category_id: category.id).joins(:amount).sum(:value), :precision => 2).to_f
      else
        total_expenses += number_with_precision(budget_report.expenses.where('date >= ? && date <= ?', start_date, end_date).joins(:amount).sum(:value), :precision => 2).to_f
      end
    end
    if category
      total_expenses += number_with_precision(report.expenses.where('date >= ? && date <= ?', start_date, end_date).where(category_id: category.id).joins(:amount).sum(:value), :precision => 2).to_f
    else
      total_expenses += number_with_precision(report.expenses.where('date >= ? && date <= ?', start_date, end_date).joins(:amount).sum(:value), :precision => 2).to_f
    end
    if total_expenses > rule.amount_value
      return true
    end
    false
  end

  def check_budget(rule, expense)
    start_date = nil
    end_date = nil
    budget_message = nil
    if rule.amount_value
      if rule.period
        # setting the start and end date based on the kind of period set by the user
        if rule.period_id == Period.id_for(:month)
          start_date = expense.date.beginning_of_month
          end_date = expense.date.end_of_month
          budget_message = " for the month of #{start_date.strftime('%B')}, #{start_date.strftime('%Y')}"
        elsif rule.period_id == Period.id_for(:week)
          start_date = expense.date.beginning_of_week
          end_date = expense.date.end_of_week
          budget_message = " for the week beginning #{start_date.to_s}"
        elsif rule.period_id == Period.id_for(:year)
          start_date = expense.date.beginning_of_year
          end_date = expense.date.end_of_year
          budget_message = " for the year #{start_date.strftime('%Y')}"
        elsif rule.period_id == Period.id_for(:day)
          start_date = end_date = expense.date
          budget_message = " for date #{start_date.strftime('%B %d, %Y')}"
        end
        return if rule.category_id && expense.category_id != rule.category_id
        if rule.category_id
          category = Category.find(rule.category_id)
        else
          category = nil
        end
        if budget_violation?(expense, rule, start_date, end_date, category)
          if rule.type == 'Warning'
            if category
              message = "Total expenses under category #{category.name} #{budget_message} have exceeded #{rule.amount_value.to_s}"
              self.warning_messages[expense.id]['budget_warning'] << {type: 'category', message: message}
            else
              message = "Total expenses #{budget_message} have exceeded #{rule.amount_value.to_s}"
              self.warning_messages[expense.id]['budget_warning'] << {type: 'total', message: message}
            end
            return
          elsif rule.type == 'Blocking'
            if category
              message = "Total expenses under category #{category.name} #{budget_message} have exceeded #{rule.amount_value.to_s}"
              self.warning_messages[expense.id]['budget_blocking'] << {type: 'category', message: message}
            else
              message = "Total expenses #{budget_message} have exceeded #{rule.amount_value.to_s}"
              self.warning_messages[expense.id]['budget_blocking'] << {type: 'total', message: message}
            end
            return
          end
        end
      end
    end
  end
end