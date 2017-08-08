class AddPaymentPurposeToPaymentOrder < ActiveRecord::Migration
  def change
    add_column :payment_orders, :payment_purpose_id, :integer, references: 'PaymentPurpose', index: true, foreign_key: true
    if PaymentOrder.column_names.include?('payment_order_type_id')
      PaymentOrder.all.where(payment_order_type_id: 1).update_all(payment_purpose_id: PaymentPurpose.id_for(:meal_benefit))
      PaymentOrder.all.where(payment_order_type_id: 2).update_all(payment_purpose_id: PaymentPurpose.id_for(:medical_benefit))
      PaymentOrder.all.where(payment_order_type_id: 3).update_all(payment_purpose_id: PaymentPurpose.id_for(:advance))
      PaymentOrder.all.where(payment_order_type_id: 4).update_all(payment_purpose_id: PaymentPurpose.id_for(:reimbursement))
    end
    change_column_null :payment_orders, :payment_purpose_id, false
    remove_foreign_key :payment_orders, column: :payment_order_type_id
    remove_index :payment_orders, :payment_order_type_id
    remove_column :payment_orders, :payment_order_type_id
  end
end
