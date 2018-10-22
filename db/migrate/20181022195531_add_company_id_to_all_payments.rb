class AddCompanyIdToAllPayments < ActiveRecord::Migration
  def change
    PaymentOrder.all.each do |po|
      company_id = po.company_id
      po.payments.update_all(company_id: company_id)
    end
  end
end