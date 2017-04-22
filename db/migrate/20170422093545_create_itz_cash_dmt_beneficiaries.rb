class CreateItzCashDmtBeneficiaries < ActiveRecord::Migration
  def change
    create_table :itz_cash_dmt_beneficiaries do |t|
      t.string :first_name, null: false
      t.string :middle_name
      t.string :last_name, null: false
      t.string :mobile_number, null: false
      t.string :relation, null: false
      t.string :ifsc_option, null: false
      t.string :ifsc_code, null: false
      t.string :bank_name
      t.string :branch_name
      t.string :bank_city
      t.integer :state_id, null: false
      t.string :account_number, null: false
      t.integer :processing_bank_id, null: false
      t.references :itz_cash_dmt_sender, index: true, foreign_key: true, null: false
      t.integer :status_id, null: false, references: 'ItzCashDmtBeneficiaryStatus', index: true, foreign_key: true
      t.integer :type_id, null: false, references: 'ItzCashDmtBeneficiaryType', index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
