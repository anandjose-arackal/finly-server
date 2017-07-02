class CreateKycStatuses < ActiveRecord::Migration
  def change
    create_table :kyc_statuses do |t|
      t.string :name

      t.timestamps null: false
    end
    KycStatus.seed_data
  end
end
