class PopulateCompanyIdInBankPaymentRequests < ActiveRecord::Migration[5.2]

  def change
    BankPaymentRequest.all.find_each do |bpr|
      bpr.company_id = bpr.owner.company_id
      bpr.save
    end
  end
end
