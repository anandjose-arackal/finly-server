class SeedPaymentTermsForExistingCompanies < ActiveRecord::Migration[4.2]
  def change
    Company.all.each do |company|
      PaymentTerm.seed_defaults(company.id)
    end
  end
end
