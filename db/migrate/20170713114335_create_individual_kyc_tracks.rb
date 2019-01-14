class CreateIndividualKycTracks < ActiveRecord::Migration[4.2]
  def change
    create_table :individual_kyc_tracks do |t|
      t.references :individual_kyc, index: true, foreign_key: true, null: false
      t.integer :action_resource_id, index: true
      t.string :action_resource_type, index: true
      t.integer :action_id, references: 'IndividualKycTrackAction', index: true, foreign_key: true, null: false
      t.text :note

      t.timestamps null: false
    end
  end
end
