class AddPolicyToExpenseRules < ActiveRecord::Migration
  def change
    add_reference :expense_rules, :policy, index: true, foreign_key: true
  end
end
