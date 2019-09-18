class CreatePaymentAgreementStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_agreement_statuses do |t|
      t.string :name

      t.timestamps
    end
  end
end
