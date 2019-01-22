class CreateCompanyKycTrackActions < ActiveRecord::Migration[4.2]
  def change
    create_table :company_kyc_trail_actions do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
