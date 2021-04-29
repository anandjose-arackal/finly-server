class UpdateBaseCurrencyForBankPaymentRequest < ActiveRecord::Migration[6.0]
  def change
    ActsAsTenant.without_tenant do
      BankPaymentRequest.all.update_all(base_currency_id: Currency.find_by(country_code: 'INR').id )  
    end
  end
end
