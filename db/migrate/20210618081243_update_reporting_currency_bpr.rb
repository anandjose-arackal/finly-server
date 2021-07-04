class UpdateReportingCurrencyBpr < ActiveRecord::Migration[6.0]
  def change
    ActsAsTenant.without_tenant do
      BankPaymentRequest.where(reporting_currency_id: nil).update_all(reporting_currency_id: Currency.find_by(country_code: 'INR').id )  
    end
  end
end
