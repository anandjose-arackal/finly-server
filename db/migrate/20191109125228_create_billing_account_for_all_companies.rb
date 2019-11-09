class CreateBillingAccountForAllCompanies < ActiveRecord::Migration[5.2]
  def change
    Company.all.each do |company|
      company.build_billing_account(enabled: true, balance_attributes: {value: 0, currency_id: Currency.first.id}).save
    end
  end
end
