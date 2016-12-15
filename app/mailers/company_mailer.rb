class CompanyMailer < ApplicationMailer

  def balance_update(transaction_details)
    @amount = transaction_details[:amount_attributes][:value] rescue nil
    @reference_id = transaction_details[:reference_id]
    @date = transaction_details[:date]
    @remarks = transaction_details[:remark]
    @company = transaction_details[:company]
    mail to: Constants::ITZCASH_EMAIL_ID, subject: "Transaction Details for Company: #{transaction_details[:company]}"
  end

end
