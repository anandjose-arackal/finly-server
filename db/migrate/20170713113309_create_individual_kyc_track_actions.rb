class CreateIndividualKycTrackActions < ActiveRecord::Migration[4.2]
  def change
    create_table :individual_kyc_track_actions do |t|
      t.string :name, null: false, index: true

      t.timestamps null: false
    end
    if Company.count > 0
      IndividualKycTrackAction.seed_data
    end
  end
end
