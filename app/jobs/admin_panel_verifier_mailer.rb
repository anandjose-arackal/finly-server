class AdminPanelVerifierMailer < ActiveJob::Base

  def perform
    return unless valid_working_hours
    admin_users = AdminUser.with_id(AdminReviewWorkflowLevel.trigger_email.pluck(:admin_user_id)).uniq
    admin_users.each do |user|
      last_email_triggered_at = AdminReviewWorkflowLevel.with_admin_user(user.id).sort_by_email_triggered_at_desc.first&.email_triggered_at
      event_presenter = Event::EAdmin::EVerifier::PendingAlert.(user, after: last_email_triggered_at)
      if event_presenter.success?
        AdminReviewWorkflowLevel.with_admin_user(user.id).update_all(email_triggered_at: DateTime.now)
      end
    end
  end

  protected
  def valid_working_hours
    # Check if the current weekday is between monday and friday
    return false unless [*1..5].include? Date.today.wday

    # Check if time is between 9am and 6pm
    today = Date.today
    staring_hours = Time.local(today.year, today.month, today.day, 9, 0, 0)
    ending_hours = Time.local(today.year, today.month, today.day, 18, 0, 0)
    return false unless (staring_hours..ending_hours).include? Time.now
    true
  end

end