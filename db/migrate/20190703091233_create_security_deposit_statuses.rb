class CreateSecurityDepositStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :security_deposit_statuses do |t|
      t.string :name

      t.timestamps
    end
  end
end
