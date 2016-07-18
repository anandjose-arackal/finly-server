class ViolationService < BaseService

  include ActionView::Helpers::NumberHelper

  attr_accessor :warning_messages

  def initialize(current_user)
    @user = current_user

    # setting up the structure of the warning_messages hash
    self.warning_messages = {}
  end

  # checks for policy violations in a report and returns returns false if there aren't any
  def violations(policy=nil, report=nil)
    if report.nil?
      errors << "No report passed."
      return false
    end
    if policy.nil?
      return true
    end

    report.expenses.each do |expense|
      # initializing the warning_messages hash
      self.warning_messages[expense.id] = {}
      self.warning_messages[expense.id]['expense_warning'] = {}
      self.warning_messages[expense.id]['expense_blocking'] = {}
      self.warning_messages[expense.id]['budget_warning'] = {}
      self.warning_messages[expense.id]['budget_blocking'] = {}
      

      policy.expense_rules.each do |rule|
        check_expense_rule rule, expense
      end
      policy.budget_rules.each do |rule|
        check_budget rule, expense
      end
    end

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
        message += " and belonging to category " + expense.category_name
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
      if rule.type == 'Warning'
        if self.warning_messages[expense.id]['expense_warning'][rule_name].nil?
          self.warning_messages[expense.id]['expense_warning'][rule_name] = [warning]
        else
          self.warning_messages[expense.id]['expense_warning'][rule_name] << warning
        end
      elsif rule.type == 'Blocking'
        if self.warning_messages[expense.id]['expense_blocking'][rule_name].nil?
          self.warning_messages[expense.id]['expense_blocking'][rule_name] = [warning]
        else
          self.warning_messages[expense.id]['expense_blocking'][rule_name] << warning
        end
      end
    end
  end

  def budget_violation?(expense, rule, start_date, end_date, category = nil)
    user = expense.user
    report = expense.report
    total_expenses = 0
    # all user reports with the associated budget
    user.reports.where(policy_id: rule.policy_id).where.not(id: report.id).each do |budget_report|
      if category
        total_expenses += number_with_precision(budget_report.expenses.where("status = ? OR status = ?", 1, 2).where('date >= ? && date <= ?', start_date, end_date).where(category_id: category.id).joins(:amount).sum(:value), :precision => 2).to_f
      else
        total_expenses += number_with_precision(budget_report.expenses.where("status = ? OR status = ?", 1, 2).where('date >= ? && date <= ?', start_date, end_date).joins(:amount).sum(:value), :precision => 2).to_f
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
              self.warning_messages[expense.id]['budget_warning'][category.name] = "Total expenses under category " + category.name + budget_message + " have exceeded " + rule.amount_value.to_s
            else
              self.warning_messages[expense.id]['budget_warning']['total'] = "Total expenses " + budget_message + " have exceeded " + rule.amount_value.to_s
            end
            return
          elsif rule.type == 'Blocking'
            if category
              self.warning_messages[expense.id]['budget_blocking'][category.name] = "Total expenses under category " + category.name + budget_message + " have exceeded " + rule.amount_value.to_s
            else
              self.warning_messages[expense.id]['budget_blocking']['total'] = "Total expenses " + budget_message + " have exceeded " + rule.amount_value.to_s
            end
            return
          end
        end
      end
    end
  end

end