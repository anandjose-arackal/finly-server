class CreateIndividualKycs < ActiveRecord::Migration
  def change
    create_table :individual_kycs do |t|
      t.attachment :id_proof
      t.attachment :pan_card
      t.references :kyc_status
      t.references :user, null: false, index: true, foreign_key: true

      t.timestamps null: false
    end
    User.all.each do |user|
      user.build_individual_kyc(kyc_status_id: KycStatus.id_for(:incomplete)).save
    end
  end
end
