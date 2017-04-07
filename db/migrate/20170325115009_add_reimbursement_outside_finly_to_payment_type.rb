class AddReimbursementOutsideFinlyToPaymentType < ActiveRecord::Migration
  if PaymentType.count > 0 and PaymentType.find_by(name: 'reimbursement_outside_finly').blank?
    payment_type = PaymentType.create id: PaymentType.id_for(:reimbursement_outside_finly), name: 'reimbursement_outside_finly'
    Payment.with_payment_type_id(PaymentType.id_for(:reimbursement)).update_all(payment_type_id: payment_type)
  end
end
