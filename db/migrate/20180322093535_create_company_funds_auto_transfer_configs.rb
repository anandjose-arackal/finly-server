class CreateCompanyFundsAutoTransferConfigs < ActiveRecord::Migration[4.2]
  def change
    create_table :company_funds_auto_transfer_configs do |t|
      t.references :company, index: true, foreign_key: true
      t.integer :threshold_amount_id, references: "Amount", foreign_key: true, index: true
      t.string :frequency_name
      t.string :frequency_day
      t.string :amount_transfer_type

      t.timestamps null: false
    end
  end
end
