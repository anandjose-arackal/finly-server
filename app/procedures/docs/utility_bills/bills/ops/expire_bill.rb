class Docs::UtilityBills::Bills::Ops::ExpireBill < Transactions::API
  step :init
  step Model(BbpsBill, :find_by)
  step :expire_bill

  def init(options, params:, **)
    params[:id] = params[:bill_id]
  end

  def expire_bill(options, current_user:, params:, model:, **)
    bill = model
    if bill.present?
	    bill.errors.add(:error, 'This bill is expired' )
	    bill.payments.each do |payment|
	      payment.system_messages.create({
	                                         content: 'Bill expired',
	                                         system_message_type_id: SystemMessageType.id_for(:error)
	                                     })
	    end
	    bill.update(status_id: BbpsBillStatus.id_for(:expired))
	    bill.payments.update_all(payment_status_id: PaymentStatus.id_for(:failed))
    end
    true
  end
end