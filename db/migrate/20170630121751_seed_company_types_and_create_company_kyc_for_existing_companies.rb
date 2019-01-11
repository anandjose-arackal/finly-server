class SeedCompanyTypesAndCreateCompanyKycForExistingCompanies < ActiveRecord::Migration[4.2]
  def change
    # seeding company types for data
    CompanyType.seed_data

    # looping through companies and creating a company kyc model for them if not already present
    Company.all.each do |company|
      unless company.company_kyc.present?
        # todo - change this to create it based on each actual company
        company.build_company_kyc(company_type_id: 3, kyc_status_id: KycStatus.id_for()).save
      end
    end

    # 
  end
end
