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
  attr_accessor :no_policy, :warning_messages, :policy, :base_currency_code, :base_currency_id

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
    self.base_currency_code = policy.nil? ? (user.company.base_currency.country_code) : (policy.base_currency.country_code)
    self.base_currency_id = policy.nil? ? (user.company.base_currency.id) : (policy.base_currency.id)
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

    report.expenses.each do |expense|
      # because the incompatible expense violation needs to be calculated irrespective of the
      # existence of a policy
      check_compatible_expenses(expense)
      check_non_base_currency(expense)
      check_custom_fields(expense)
      # i.e. if the expense does not have a possible currency computation skip rule checking because the amount isn't clear
      if expense.amount&.currency_id != base_currency_id && expense.date == DateUtils.local_date
        next
      end

      unless no_policy
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
    if rule.greater_than_amount_value && rule.greater_than_amount_value != 0
      if expense.amount.send(base_currency_code.to_sym) >= rule.greater_than_amount_value
        message += ' above ' + rule.greater_than_amount_value.to_s
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
      when 4 #Receipt hard copy required
        hard_copy = true
        expense.receipts.each do |r|
          unless r.hard_copy_received
            hard_copy = false
          end
        end

        if hard_copy
          message = false
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
    warning += ' require receipt hard copy submission' if rule.expense_rule_type_id == 4
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
      when 4
        rule_name = 'receipt_hard_copy'
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
    user.reports.processed.with_policy_id(rule.policy_id).where.not(id: report.id).each do |budget_report|
      if rule.include_reimbursable_expenses?
        total_expenses += number_with_precision(budget_report.expenses.with_date_range(start_date, end_date).filter_category_id(category&.id).joins(:amount).sum(base_currency_code.to_sym), :precision => 2).to_f
      else
        total_expenses += number_with_precision(budget_report.expenses.reimbursable.with_date_range(start_date, end_date).filter_category_id(category&.id).joins(:amount).sum(base_currency_code.to_sym), :precision => 2).to_f
      end
    end
    if rule.include_reimbursable_expenses?
      total_expenses += number_with_precision(report.expenses.with_date_range(start_date, end_date).filter_category_id(category&.id).joins(:amount).sum(base_currency_code.to_sym), :precision => 2).to_f
    else
      total_expenses += number_with_precision(report.expenses.reimbursable.with_date_range(start_date, end_date).filter_category_id(category&.id).joins(:amount).sum(base_currency_code.to_sym), :precision => 2).to_f
    end
    if total_expenses > rule.amount.send(base_currency_code.to_sym)
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
              message = "Total expenses under category #{category.name} #{budget_message} have exceeded #{rule.amount.currency.symbol}#{rule.amount_value.to_s} #{rule.amount.currency.country_code}"
              self.warning_messages[expense.id]['budget_warning'] << {type: 'category', message: message}
            else
              message = "Total expenses #{budget_message} have exceeded #{rule.amount.currency.symbol}#{rule.amount_value.to_s} #{rule.amount.currency.country_code}"
              self.warning_messages[expense.id]['budget_warning'] << {type: 'total', message: message}
            end
            return
          elsif rule.type == 'Blocking'
            if category
              message = "Total expenses under category #{category.name} #{budget_message} have exceeded #{rule.amount.currency.symbol}#{rule.amount_value.to_s} #{rule.amount.currency.country_code}"
              self.warning_messages[expense.id]['budget_blocking'] << {type: 'category', message: message}
            else
              message = "Total expenses #{budget_message} have exceeded #{rule.amount.currency.symbol}#{rule.amount_value.to_s} #{rule.amount.currency.country_code}"
              self.warning_messages[expense.id]['budget_blocking'] << {type: 'total', message: message}
            end
            return
          end
        end
      end
    end
  end

  # method that checks for whether a Distance/Time/Per Diem expense is enabled for the particular report policy
  # (or company if no policy is selected) and adds a blocking violation if it's not
  def check_compatible_expenses(expense)
    message = "Expenses are not enabled for the selected policy. Please change the policy of the report or remove the expense"
    case expense.expense_type_id
      when ExpenseType.id_for(:distance)
        unless report.policy.distance_expense_config.enabled
          self.warning_messages[expense.id]['expense_blocking'] << {type: 'incompatible', message: "Distance #{message}"}
          return
        end
      when ExpenseType.id_for(:time)
        unless report.policy.time_expense_config.enabled
          self.warning_messages[expense.id]['expense_blocking'] << {type: 'incompatible', message: "Time #{message}"}
          return
        end
      when ExpenseType.id_for(:per_diem)
        if report.policy.per_diem_expense_config.enabled
          if report.policy.per_diems.include?(expense.per_diem_expense.per_diem)
            return
          else
            message = "of some expenses do not belong to the selected policy"
            self.warning_messages[expense.id]['expense_blocking'] << {type: 'incompatible', message: "Some Per Diem #{message}"}
          end
        else
          self.warning_messages[expense.id]['expense_blocking'] << {type: 'incompatible', message: "Per Diem #{message}"}
          return
        end
      else
        # do nothing
    end
  end

  def check_non_base_currency(expense)
    if expense.date == DateUtils.local_date
      if expense&.amount.currency_id == base_currency_id
        return
      else
        self.warning_messages[expense.id]['expense_blocking'] << {type: 'non_base_currency', message: "Expenses that are reported in a different currency from #{base_currency_code} can only be submitted the next day"}
      end
    end
  end

  def check_custom_fields(expense)
    exp = expense.sub_expense
    valid = CustomField::Validate.(exp)
    unless valid.success?
      valid.messages[:error]&.each do |message|
        self.warning_messages[expense.id]['expense_blocking'] << {type: 'custom_fields', message: message}
      end
    end
  end

end
