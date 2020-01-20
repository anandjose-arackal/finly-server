class PopulateTaxRateIdInBeneficiaryPayments < ActiveRecord::Migration[5.2]
  def change
    Company.all.find_each do |company|
      company.beneficiary_payments.where.not(tax: nil).where(tax_rate_id: nil).find_each do |beneficiary_payment|
        if beneficiary_payment.tax_rate_id.blank?
          tax = beneficiary_payment.tax.to_f
          tax_rate_id = company.tax_rates.where(rate: tax).first.id rescue nil
          if beneficiary_payment.tax_rate_id.blank? && tax_rate_id.present?
            beneficiary_payment.update_column('tax_rate_id', tax_rate_id)
          end
        end    
      end
    end
  end
end
