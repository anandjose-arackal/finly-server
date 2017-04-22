class CreateItzCashDmtBeneficiaryStatuses < ActiveRecord::Migration
  def change
    create_table :itz_cash_dmt_beneficiary_statuses do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
