class AddOtherDocumentsToCompanyKyc < ActiveRecord::Migration[4.2]
  def change
    change_table :company_kycs do |t|
      t.attachment :aadhar_card
      t.attachment :vat_registration_certificate
      t.attachment :registration_of_trust
      t.attachment :driving_licence
      t.attachment :passport
    end

    Company.all.each do |company|
      company.build_company_kyc(kyc_status_id: KycStatus.id_for(:incomplete)).save
    end
  end
end
