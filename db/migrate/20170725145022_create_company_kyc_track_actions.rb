class CreateCompanyKycTrackActions < ActiveRecord::Migration
  def change
    create_table :company_kyc_trail_actions do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
