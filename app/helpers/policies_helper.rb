module PoliciesHelper

  def rule_in_words (rule)

    if rule.is_a?(ExpenseRule)
        rule_in_words = "Expenses"
        if rule.category_id
          rule_in_words += " belonging to category " + rule.category_name
        end
        if rule.days_after
          rule_in_words += " submitted after " + rule.days_after.to_s + " days"
        end
        if rule.greater_than_amount_id and rule.greater_than_amount_value > 0
          rule_in_words += " with amount greater than #{rule.greater_than_amount.currency.symbol}#{rule.amount_value.to_s} #{rule.greater_than_amount.currency.country_code}"
        end
        case rule.expense_rule_type_id
          when 1
            rule_in_words += " require a receipt."
          when 2
            rule_in_words += " require a note."
          when 3
            rule_in_words += " are not allowed"
          when 4
            rule_in_words += " require receipt hard copy."
        end
    elsif rule.is_a?(BudgetRule)
        rule_in_words = "Total Expenses"
        if rule.period_id
          case rule.period_id
            when 1
              period = "day"
            when 2
              period = "week"
            when 3
              period = "month"
            when 4
              period = "year"
          end
          rule_in_words += " per " + period
        end
        if rule.category_id
          rule_in_words += " belonging to category " + rule.category_name
        end
        if rule.amount_id
          rule_in_words += " should not exceed #{rule.amount.currency.symbol}#{rule.amount_value.to_s} #{rule.amount.currency.country_code}"
        end
    end
    rule_in_words
  end

end
