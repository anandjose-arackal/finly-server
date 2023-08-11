class UnapprovedTransactionRemindersToggle < ApplicationToggle
  def enabled?
    feature_flag 'feature/unapproved_transaction_reminders#enabled', false
  end
end
