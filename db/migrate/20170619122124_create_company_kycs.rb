class CreateCompanyKycs < ActiveRecord::Migration
  def change
    create_table :company_kycs do |t|
      t.attachment :pan_card
      t.attachment :coi
      t.attachment :agreement
      t.attachment :board_resolution
      t.references :kyc_status
      t.references :company, null:false, index: true, foreign_key: true

      t.timestamps null: false
    end
    Company.all.each do |company|
      company.build_company_kyc(kyc_status_id: KycStatus.id_for(:incomplete)).save
    end
  end
end
