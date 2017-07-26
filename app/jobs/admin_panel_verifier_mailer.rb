class AdminPanelVerifierMailer < ActiveJob::Base

  def perform
    return unless valid_working_hours
    notify_assign_requests
    notify_upgrade_requests
  end

  protected
  def notify_assign_requests
    assign_workflow_id = AdminReviewWorkflow.id_for :assign_card
    admin_users = AdminUser.with_id(AdminReviewWorkflowLevel.with_review_workflow(assign_workflow_id).trigger_email.pluck(:admin_user_id)).uniq
    admin_users.each do |user|
      last_email_triggered_at = AdminReviewWorkflowLevel.with_admin_user(user.id).sort_by_email_triggered_at_desc.first&.email_triggered_at
      event_presenter = Event::EAdmin::EVerifier::AssignAlert.(user, after: last_email_triggered_at)
      if event_presenter.success?
        AdminReviewWorkflowLevel.with_admin_user(user.id).update_all(email_triggered_at: DateTime.now)
      end
    end
  end

  # Notify new assign requests with KYC and new KYC Upgrade requests
  def notify_upgrade_requests
    upgrade_workflow_id = AdminReviewWorkflow.id_for :kyc_update
    admin_users = AdminUser.with_id(AdminReviewWorkflowLevel.with_review_workflow(upgrade_workflow_id).trigger_email.pluck(:admin_user_id)).uniq
    admin_users.each do |user|
      last_email_triggered_at = AdminReviewWorkflowLevel.with_admin_user(user.id).sort_by_email_triggered_at_desc.first&.email_triggered_at
      event_presenter = Event::EAdmin::EVerifier::PendingAlert.(user, after: last_email_triggered_at)
      if event_presenter.success?
        AdminReviewWorkflowLevel.with_admin_user(user.id).update_all(email_triggered_at: DateTime.now)
      end
    end
  end

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