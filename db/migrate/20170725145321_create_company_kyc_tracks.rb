class CreateCompanyKycTracks < ActiveRecord::Migration[4.2]
  def change
    create_table :company_kyc_trails do |t|
      t.references :company_kyc, index: true, foreign_key: true
      t.integer :action_resource_id
      t.string :action_resource_type
      t.integer :action_id
      t.text :note

      t.timestamps null: false
    end
  end
end
