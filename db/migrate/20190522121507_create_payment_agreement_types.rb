class CreatePaymentAgreementTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_agreement_types do |t|
      t.integer :name

      t.timestamps
    end
  end
end
