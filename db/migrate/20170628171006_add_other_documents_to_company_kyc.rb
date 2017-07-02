class AddOtherDocumentsToCompanyKyc < ActiveRecord::Migration
  def change
    change_table :company_kycs do |t|
      t.attachment :aadhar_card
      t.attachment :vat_registration_certificate
      t.attachment :registration_of_trust
      t.attachment :driving_licence
      t.attachment :passport
    end
  end
end
