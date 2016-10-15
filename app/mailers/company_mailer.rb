class CompanyMailer < ApplicationMailer

  def balance_update(transaction_details)
    @amount = transaction_details[:amount]
    @reference_id = transaction_details[:transaction_id]
    @date = transaction_details[:date]
    @remarks = transaction_details[:remarks]
    mail to: CONSTANTS::ITZCASH_EMAIL_ID, subject: 'Welcome to Finly!'
  end
end