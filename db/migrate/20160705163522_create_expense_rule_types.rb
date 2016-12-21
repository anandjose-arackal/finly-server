class CreateExpenseRuleTypes < ActiveRecord::Migration
  def change
    create_table :expense_rule_types do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
