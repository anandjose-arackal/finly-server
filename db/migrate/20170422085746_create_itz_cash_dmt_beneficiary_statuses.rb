class CreateItzCashDmtBeneficiaryStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :itz_cash_dmt_beneficiary_statuses do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
