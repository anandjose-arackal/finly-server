class CreateKycStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :kyc_statuses do |t|
      t.string :name

      t.timestamps null: false
    end
    KycStatus.seed_data
  end
end
