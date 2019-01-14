class PopulateCashCardExpenseConfigData < ActiveRecord::Migration[4.2]
  def change
    Policy.all.each do |policy|
      CashExpenseConfig.create(policy_id: policy.id, enabled: true)
      CardExpenseConfig.create(policy_id: policy.id, enabled: true)
    end
  end
end
