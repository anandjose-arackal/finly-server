class AddCertificateOfRegistrationToCompanyKyc < ActiveRecord::Migration[4.2]
  def change
    change_table :company_kycs do |t|
      t.attachment :certificate_of_registration
    end
  end
end
