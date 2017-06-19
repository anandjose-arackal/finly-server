class CreateCorporateKycs < ActiveRecord::Migration
  def change
    create_table :corporate_kycs do |t|
      t.attachment :pan_card
      t.attachment :coi
      t.attachment :agreement
      t.attachment :board_resolution
      t.reference :kyc_status

      t.timestamps null: false
    end
  end
end
