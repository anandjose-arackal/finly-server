class UnapprovedTransactionRemindersToggle < ApplicationToggle
  def disabled?
    feature_flag 'feature/unapproved_transaction_reminders#enabled', false
  end
  
  def enabled?
    !disabled?
  end
end
