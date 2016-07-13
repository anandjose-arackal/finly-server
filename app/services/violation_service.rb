class ViolationService < BaseService

  attr_accessor :warning_messages

  def initialize(current_user)
    @user = current_user
    warning_messages = {}
  end

  # checks for policy violations in a report and returns returns false if there aren't any
  def violations(policy, report)

    # loading expenses from report
    expenses = report.expenses

    ###### change this later to retrieve the policy from the report
    policy = PolicyRetrievalService.list(@user).first
    apply_policy_for_report(report, policy)

  end

  private

  def check_expense_rule_violation(expense, rule, manager = nil)
    message = ""
    if rule.amount_value
      if expense.amount_value >= rule.amount_value
        message += " above " + rule.amount_value.to_s
      else
        return false
      end
    end
    if rule.category_id
      if expense.category_id == rule.category_id
        message += " and belonging to category " + expense.category_name.name
      else
        return false
      end
    end
    if rule.days_after
      if manager
        time_elapsed = (expense.report.submitted_at - expense.date).to_i
      else
        time_elapsed = (Date.today - expense.date).to_i
      end
      if time_elapsed > rule.days_after
        message += " added after " + rule.days_after.to_s + " days"
      else
        return false
      end
    end
    message
  end


  # checks the passed expense against the passed rule
  def check_expense_rule(rule, expense, manager = nil)
    warning = "Expenses"
    broken = false
    # first check if there's a violation with the common criteria
    message = check_expense_rule_violation(expense, rule, manager)
    # checking if the specific rule is actually broken
    case rule.expense_rule_type_id
      when 1
        if expense.receipt_file_name
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
    warning += " require a receipt." if rule.expense_rule_type_id == 1
    warning += " require a note." if rule.expense_rule_type_id == 2
    warning += " are not allowed." if rule.expense_rule_type_id == 3

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
      if rule.type == 'warning'
        if warning_messages[expense.id]['warning'][rule_name].nil?
          warning_messages[expense.id]['warning'][rule_name] = [warning]
        else
          warning_messages[expense.id]['warning'][rule_name] << warning
        end
      elsif rule.type == 'blocking'
        if warning_messages[expense.id]['blocking'][rule_name].nil?
          warning_messages[expense.id]['blocking'][rule_name] = [warning]
        else
          warning_messages[expense.id]['blocking'][rule_name] << warning
        end
      end
    end
  end

  def budget_violation?(expense, rule, start_date, end_date, category = nil)
    user = expense.user
    report = expense.report
    total_expenses = 0
    # all user reports with the associated budget
    user.reports.where(policy_id: rule.policy_id).where.not(id: self.id).each do |budget_report|
      if category
        total_expenses += number_with_precision(budget_report.expenses.where("status = ? OR status = ?", 1, 2).where('date >= ? && date <= ?', start_date, end_date).where(category_id: category.id).sum(:amount), :precision => 2).to_f
      else
        total_expenses += number_with_precision(budget_report.expenses.where("status = ? OR status = ?", 1, 2).where('date >= ? && date <= ?', start_date, end_date).sum(:amount), :precision => 2).to_f
      end
    end
    if category
      total_expenses += number_with_precision(report.expenses.where('date >= ? && date <= ?', start_date, end_date).where(category_id: category.id).sum(:amount), :precision => 2).to_f
    else
      total_expenses += number_with_precision(report.expenses.where('date >= ? && date <= ?', start_date, end_date).sum(:amount), :precision => 2).to_f
    end
    if total_expenses > rule.amount
      return true
    end
    false
  end

  def check_budget(rule, expense)
    if rule.amount_value
      if rule.period
        # setting the start and end date based on the kind of period set by the user
        if rule.period == 'Month'
          start_date = expense.date.beginning_of_month
          end_date = expense.date.end_of_month
          budget_message = " for the month of " + start_date.strftime("%B") + ", " + start_date.strftime("%Y")
        elsif rule.period == 'Week'
          start_date = expense.date.beginning_of_week
          end_date = expense.date.end_of_week
          budget_message = " for the week beginning " + start_date.to_s
        elsif rule.period == 'Year'
          start_date = expense.date.beginning_of_year
          end_date = expense.date.end_of_year
          budget_message = " for the year " + start_date.strftime("%Y")
        elsif rule.period == 'Day'
          start_date = end_date = expense.date
          budget_message = " for date " + start_date.strftime("%B %d, %Y")
        end
        return if expense.category_id != rule.category_id && rule.category_id
        if rule.category_id
          category = Category.find(rule.category_id)
        else
          category = nil
        end
        if budget_violation?(expense, rule, start_date, end_date, category)
          if rule.type == 'Warning'
            if category
              warning_messages[expense.id]['Warning'][category.name] = "Total expenses under category " + category.name + budget_message + " have exceeded " + rule.amount.to_s
            else
              warning_messages[expense.id]['Warning']['total'] = "Total expenses " + budget_message + " have exceeded " + rule.amount.to_s
            end
            return
          elsif rule.type == 'Blocking'
            if category
              warning_messages[expense.id]['Blocking'][category.name] = "Total expenses under category " + category.name + budget_message + " have exceeded " + rule.amount.to_s
            else
              warning_messages[expense.id]['Blocking']['total'] = "Total expenses " + budget_message + " have exceeded " + rule.amount.to_s
            end
            return
          end
        end
      end
    end
  end

  def apply_policy_for_report(report = nil, policy = nil)
    unless report || policy
      errors << "No report or policy passed."
      return false
    end
    report.expenses.each do |expense|
      policy.expense_rules.each do |rule|
        check_expense_rule rule, expense
      end
      policy.budget_rules.each do |rule|
        check_budget rule, expense
      end
    end
  end

end