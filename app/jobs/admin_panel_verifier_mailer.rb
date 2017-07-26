class AdminPanelVerifierMailer < ActiveJob::Base

  def perform
    admin_users = AdminUser.with_id(AdminReviewWorkflowLevel.trigger_email.pluck(:admin_user_id))
    admin_users.each do |user|
      Event::EAdmin::EVerifier::PendingAlert.(user)
      AdminReviewWorkflowLevel.with_admin_user(user.id).update_all(email_triggered_at: DateTime.now)
    end
  end

end