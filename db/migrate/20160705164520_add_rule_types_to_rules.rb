class AddRuleTypesToRules < ActiveRecord::Migration
  def change
    add_reference :expense_rules, :rule_type, index: true, foreign_key: true
    add_reference :expense_rules, :expense_rule_type, index: true, foreign_key: true
    add_reference :budget_rules, :rule_type, index: true, foreign_key: true
  end
end
