class CreateCorporateKycs < ActiveRecord::Migration
  def change
    create_table :corporate_kycs do |t|
      t.references :company
      t.attachment :pan_card
      t.attachment :coi
      t.attachment :agreement
      t.attachment :board_resolution
      t.references :kyc_status

      t.timestamps null: false
    end
    Company.all.each do |company|
      company.build_corporate_kyc(kyc_status_id: KycStatus.id_for(:incomplete)).save if company.corporate_kyc.blank?
    end
  end
end
