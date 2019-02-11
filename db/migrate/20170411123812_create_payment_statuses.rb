class CreatePaymentStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :payment_statuses do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
    PaymentStatus.seed_data
    add_column :payments, :payment_status_id, :integer, null: false, index: true, foreign_key: true, references: 'PaymentStatus'
    if Payment.count > 0
      Payment.all.update_all(payment_status_id: PaymentStatus.id_for(:completed))
    end
  end
end
