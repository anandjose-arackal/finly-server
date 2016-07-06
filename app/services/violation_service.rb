class ViolationService < BaseService

  def initialize(current_user)
    @user = current_user

  end

  def violations(policy, report)

    # placeholder for rules - can later be loaded from rules engine, or any other method
    expense_rules = policy.expense_rules
    budget_rules = policy.budget_rules

    # currently loading as an array of expenses, will later be loaded from report
    expenses = report


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
    if rule.days_before
      time_elapsed = (Date.today - expense.date).to_i
      if time_elapsed <= rule.days_before
        expense.auto_approved = true
      else
        return false
      end
    end

    message
  end


  # checks the passed expense against the passed rule
  def check_rule(rule, expense, rule_name, manager = nil)
    warning = "Expenses"
    broken = false
    # first check if there's a violation with the common criteria
    message = check_violation(expense, rule, manager)
    # checking if the specific rule is actually broken
    case rule_name
      when 'receipt'
        if expense.receipt_file_name
          message = false # i.e. the rule is not broken because there is a receipt
        end
      when 'note'
        if expense.note && !expense.note.blank?
          message = false # i.e. the rule is not broken because there is a note
        end
      else
        # do nothing
    end
    if message
      expense.auto_approved = true if rule_name == 'auto_approve'
      warning += message
      broken = true
    end
    warning += " require a receipt." if rule_name == 'receipt'
    warning += " require a note." if rule_name == 'note'
    warning += " are not allowed." if rule_name == 'disallow'

    if broken && rule_name!='auto_approve'
      if rule.rule_type == 'warning'
        if self.warning_messages[expense.id]['warning'][rule_name].nil?
          self.warning_messages[expense.id]['warning'][rule_name] = [warning]
        else
          self.warning_messages[expense.id]['warning'][rule_name] << warning
        end
      elsif rule.rule_type == 'blocking'
        if self.warning_messages[expense.id]['blocking'][rule_name].nil?
          self.warning_messages[expense.id]['blocking'][rule_name] = [warning]
        else
          self.warning_messages[expense.id]['blocking'][rule_name] << warning
        end
      end
    end
  end

  def budget_violation?(expense, rule, start_date, end_date, category = nil)
    user = expense.user
    total_expenses = 0
    # all user reports with the associated budget
    user.reports.where(policy_id: policy.id).where.not(id: self.id).each do |budget_report|
      if category
        total_expenses += number_with_precision(budget_report.expenses.where("status = ? OR status = ?", 1, 2).where('date >= ? && date <= ?', start_date, end_date).where(category_id: category.id).sum(:amount), :precision => 2).to_f
      else
        total_expenses += number_with_precision(budget_report.expenses.where("status = ? OR status = ?", 1, 2).where('date >= ? && date <= ?', start_date, end_date).sum(:amount), :precision => 2).to_f
      end
    end
    if category
      total_expenses += number_with_precision(self.expenses.where('date >= ? && date <= ?', start_date, end_date).where(category_id: category.id).sum(:amount), :precision => 2).to_f
    else
      total_expenses += number_with_precision(self.expenses.where('date >= ? && date <= ?', start_date, end_date).sum(:amount), :precision => 2).to_f
    end
    if total_expenses > rule.amount
      return true
    end
    false
  end

  def check_budget(rule, expense)
    if rule.amount
      if rule.period
        # setting the start and end date based on the kind of period set by the user
        if rule.period == 'month'
          start_date = expense.date.beginning_of_month
          end_date = expense.date.end_of_month
          budget_message = " for the month of " + start_date.strftime("%B") + ", " + start_date.strftime("%Y")
        elsif rule.period == 'week'
          start_date = expense.date.beginning_of_week
          end_date = expense.date.end_of_week
          budget_message = " for the week beginning " + start_date.to_s
        elsif rule.period == 'year'
          start_date = expense.date.beginning_of_year
          end_date = expense.date.end_of_year
          budget_message = " for the year " + start_date.strftime("%Y")
        elsif rule.period == 'day'
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
          if rule.rule_type == 'warning'
            if category
              self.warning_messages[expense.id]['warning'][category.name] = "Total expenses under category " + category.name + budget_message + " have exceeded " + rule.amount.to_s
            else
              self.warning_messages[expense.id]['warning']['total'] = "Total expenses " + budget_message + " have exceeded " + rule.amount.to_s
            end
            return
          elsif rule.rule_type == 'blocking'
            if category
              self.warning_messages[expense.id]['blocking'][category.name] = "Total expenses under category " + category.name + budget_message + " have exceeded " + rule.amount.to_s
            else
              self.warning_messages[expense.id]['warning']['total'] = "Total expenses " + budget_message + " have exceeded " + rule.amount.to_s
            end
            return
          end
        end
      end
    end
  end


end