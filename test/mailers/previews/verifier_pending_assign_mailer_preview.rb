Dir["#{Rails.root}/app/operations/event/*.rb"].each {|file| require file }

# Preview all emails at http://localhost:3001/rails/mailers/card_transaction_mailer
require "minitest/unit"
require "mocha/mini_test"

class VerifierPendingAssignMailerPreview < ActionMailer::Preview

  # http://localhost:3001/rails/mailers/verifier_pending_mailer/pending
  def pending
    user = AdminUser.first
    params = {}
    params[:subject] = 'Test Subject'
    params[:new_card_assign_requests] = CardAssignRequest.all
    params[:new_assign_requests_count] = 3
    # params[:attachment] = ''
    params[:attachment_name] = 'new_card_assign_request.xls'
    presenter = Event::EAdmin::EVerifier::AssignAlert::MailerPresenter.new(user, params)
    VerifierPendingAssignMailer.send_mail(presenter)
  end

end