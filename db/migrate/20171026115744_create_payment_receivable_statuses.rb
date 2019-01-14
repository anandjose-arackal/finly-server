class CreatePaymentReceivableStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :payment_receivable_statuses do |t|
      t.string :name

      t.timestamps null: false
    end

    PaymentReceivableStatus.seed_data
  end
end
