class CreatePaymentAgreementEscalations < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_agreement_escalations do |t|
      t.integer :period_id
      t.integer :number
      t.decimal :percentage_increment

      t.timestamps
    end
    add_index :payment_agreement_escalations, :period_id
  end
end
