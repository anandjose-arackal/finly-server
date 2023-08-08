class UnapprovedTransactionReminderMailerPreview < ActionMailer::Preview

  # http://localhost:3001/rails/mailers/unapproved_transaction_reminder_mailer/unapproved_transaction_reminder_mail
  def unapproved_transaction_reminder_mail
    ActsAsTenant.current_tenant = Company.first
    user = User.first

    params = {
      purchase_requests: 1,
      purchase_orders: 2,
      invoices: 3,
      utility_bills: 4,
      payment_tickets: 5,
      vendors: 6,
      agreements: 7,
      utility_subscriptions: 8
    }

    unapproved_trxn = Event::EReminders::UnapprovedTransaction.new(user, params)
    
    params.merge!({
      subject: unapproved_trxn.mailer_subject,
      body: unapproved_trxn.mailer_body,
      action_name: unapproved_trxn.action_name
    }).with_indifferent_access

    UnapprovedTransactionReminderMailer.send_unapproved_transaction_mail(
      Event::EReminders::UnapprovedTransaction::MailerPresenter.new(user, params)
    )
  end
end