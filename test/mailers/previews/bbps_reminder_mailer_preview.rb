class BbpsReminderMailerPreview < ActionMailer::Preview

  # http://localhost:3001/rails/mailers/bbps_reminder_mailer/bbps_reminder_mail
  def bbps_reminder_mail
    company = Company.first
    ActsAsTenant.current_tenant = company
    user = User.first

    bill = BbpsBill
            .unscoped
            .joins(
              { subscription: [:biller, :pocs] },
              { amount: :currency },
              :department,
              :cost_center,
              :location
            )
            .select(*BbpsReminders.selected_attributes)
            .filter_status(:payables)
            .last

    if bill.present?
      params = {
        bill_id: bill.bbps_bill_id,
        utility_operator_or_vendor: bill.bbps_biller_name,
        utility_title: bill.bbps_subscription_name,
        due_date: bill.bbps_bill_due_date,
        bill_type: bill.bbps_biller_category_name,
        bill_amount: bill.base_amount_value,
        currency_country_code: bill.currency_country_code,
        bill_number: bill.bbps_bill_number,
        department: bill.department_name,
        cost_center: bill.cost_center_name,
        location: bill.location_name
      }
    else
      params = {}
    end

    bbps_subs = Event::EReminders::BbpsSubscription.new(user, params)
    
    params.merge!({
      subject: bbps_subs.mailer_subject,
      body: bbps_subs.mailer_body,
      action_name: bbps_subs.action_name
    })

    BbpsReminderMailer.send_bbps_reminder_mail(
      Event::EReminders::BbpsSubscription::MailerPresenter.new(user, params)
    )
  end
end