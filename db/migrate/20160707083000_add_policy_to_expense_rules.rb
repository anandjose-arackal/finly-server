class AddPolicyToExpenseRules < ActiveRecord::Migration[4.2]
  def change
    add_reference :expense_rules, :policy, index: true, foreign_key: true
  end
end
