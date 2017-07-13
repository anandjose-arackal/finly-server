Dir["#{Rails.root}/app/operations/event/*.rb"].each {|file| require file }

# Preview all emails at http://localhost:3001/rails/mailers/card_transaction_mailer
require "minitest/unit"
require "mocha/mini_test"

class CompanyMailerPreview < ActionMailer::Preview


  def upload_to_itzcash
    @company = Company.last
    CompanyMailer.send_to_itzcash(@company)
  end
end