Dir["#{Rails.root}/app/operations/event/*.rb"].each {|file| require file }

# Preview all emails at http://localhost:3001/rails/mailers/card_transaction_mailer
require "minitest/unit"
require "mocha/mini_test"

class VerifierPendingUpgradeMailerPreview < ActionMailer::Preview

  # http://localhost:3001/rails/mailers/verifier_pending_mailer/pending
  def pending
    user = AdminUser.first
    params = {}
    params[:subject] = 'Test Subject'
    params[:upgrade_requests_count] = 8
    params[:new_upgrade_requests_count] = 3
    params[:assign_requests_count] = 20
    params[:new_assign_requests_count] = 0
    presenter = Event::EAdmin::EVerifier::PendingAlert::MailerPresenter.new(user, params)
    VerifierPendingUpgradeMailer.send_mail(presenter)
  end
end