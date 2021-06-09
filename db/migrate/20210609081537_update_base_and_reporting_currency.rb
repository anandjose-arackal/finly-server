class UpdateBaseAndReportingCurrency < ActiveRecord::Migration[6.0]
  def change
    ActsAsTenant.without_tenant do
      
      PurchaseRequest.where(base_currency_id: nil).update_all(base_currency_id: Currency.find_by(country_code: 'INR').id )  
      PurchaseRequest.where(reporting_currency_id: nil).update_all(reporting_currency_id: Currency.find_by(country_code: 'INR').id )  
      
      PurchaseOrder.where(base_currency_id: nil).update_all(base_currency_id: Currency.find_by(country_code: 'INR').id )  
      PurchaseOrder.where(reporting_currency_id: nil).update_all(reporting_currency_id: Currency.find_by(country_code: 'INR').id )  
      
      Payment.where(base_currency_id: nil).update_all(base_currency_id: Currency.find_by(country_code: 'INR').id )  
      Payment.where(reporting_currency_id: nil).update_all(reporting_currency_id: Currency.find_by(country_code: 'INR').id )  
      
      CreditNote.where(base_currency_id: nil).update_all(base_currency_id: Currency.find_by(country_code: 'INR').id )  
      CreditNote.where(reporting_currency_id: nil).update_all(reporting_currency_id: Currency.find_by(country_code: 'INR').id )  
      
      PaymentAgreement.where(base_currency_id: nil).update_all(base_currency_id: Currency.find_by(country_code: 'INR').id )  
      PaymentAgreement.where(reporting_currency_id: nil).update_all(reporting_currency_id: Currency.find_by(country_code: 'INR').id )  
      
      InwardDocument.where(base_currency_id: nil).update_all(base_currency_id: Currency.find_by(country_code: 'INR').id )  
      InwardDocument.where(reporting_currency_id: nil).update_all(reporting_currency_id: Currency.find_by(country_code: 'INR').id )  
      
      Invoice.where(base_currency: nil).update_all(base_currency: Currency.find_by(country_code: 'INR').id )  
      Invoice.where(reporting_currency: nil).update_all(reporting_currency: 'INR' )
      
      BankPaymentRequest.where(base_currency_id: nil).update_all(base_currency_id: Currency.find_by(country_code: 'INR').id )  
      
      BbpsBill.where(base_currency_id: nil).update_all(base_currency_id: Currency.find_by(country_code: 'INR').id )  
      BbpsBill.where(reporting_currency_id: nil).update_all(reporting_currency_id: Currency.find_by(country_code: 'INR').id )  
    end
  end
end
