class CreateIndividualKycs < ActiveRecord::Migration[4.2]
  def change
    create_table :individual_kycs do |t|
      t.attachment :id_proof
      t.attachment :pan_card
      t.references :kyc_status
      t.references :user, null: false, index: true, foreign_key: true

      t.timestamps null: false
    end

  end
end
