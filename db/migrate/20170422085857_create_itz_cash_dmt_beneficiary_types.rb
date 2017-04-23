class CreateItzCashDmtBeneficiaryTypes < ActiveRecord::Migration
  def change
    create_table :itz_cash_dmt_beneficiary_types do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
