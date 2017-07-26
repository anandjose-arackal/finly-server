class AdminPanelVerifierMailer < ActiveJob::Base

  def perform
    admin_users = AdminUser.with_id(AdminReviewWorkflowLevel.trigger_email.pluck(:admin_user_id)).uniq
    admin_users.each do |user|
      last_email_triggered_at = AdminReviewWorkflowLevel.with_admin_user(user.id).sort_by_email_triggered_at_desc.first&.email_triggered_at
      event_presenter = Event::EAdmin::EVerifier::PendingAlert.(user, after: last_email_triggered_at)
      if event_presenter.success?
        AdminReviewWorkflowLevel.with_admin_user(user.id).update_all(email_triggered_at: DateTime.now)
      end
    end
  end

end