class CreateBankPaymentRequestStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :bank_payment_request_statuses do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
