class AddCertificateOfRegistrationToCompanyKyc < ActiveRecord::Migration
  def change
    change_table :company_kycs do |t|
      t.attachment :certificate_of_registration
    end
  end
end
