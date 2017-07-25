Dir["#{Rails.root}/app/operations/event/*.rb"].each {|file| require file }

# Preview all emails at http://localhost:3001/rails/mailers/card_transaction_mailer
require "minitest/unit"
require "mocha/mini_test"

class VerifierPendingMailerPreview < ActionMailer::Preview

  # http://localhost:3001/rails/mailers/verifier_pending_mailer/pending
  def pending
    @company = Company.last
    CompanyMailer.send_to_itzcash(@company)
    VerifierPendingMailer.send_mail()
  end
end