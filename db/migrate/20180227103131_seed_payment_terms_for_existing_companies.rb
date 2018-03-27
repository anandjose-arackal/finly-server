class SeedPaymentTermsForExistingCompanies < ActiveRecord::Migration
  def change
    Company.all.each do |company|
      PaymentTerm.seed_defaults(company.id)
    end
  end
end
