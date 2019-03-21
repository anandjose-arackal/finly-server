class AddCompanyIdToBpr < ActiveRecord::Migration[5.2]
  def change
    BankPaymentRequest.all.find_each do |bpr|
      bpr.update_column('company_id', bpr.owner.company_id)
    end
  end
end
