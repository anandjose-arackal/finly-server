class Admin::Payments::ChangeStatus < Admin::Payments::Base

  attr_accessor :payment, :company, :reference_resource_type


# mark the payment failed
# and retry able 

# mark the parent ticket failed / partially completed.

# mark the parent(invoice / anyother ) unpaid 
# payment = Payment.find_by(id: payment_id)
# bank_payment_request = payment.bank_payment_request
# payments = bank_payment_request.payments
# payment_statuses = payments.pluck(:payment_status_id).uniq

# if( ( payment_statuses.include?(PaymentStatus.id_for(:failed) && payment_statuses.include?(PaymentStatus.id_for(:completed) )   ))
#   payment_order = bank_payment_request.payment_order
#   payment_order.update(payment_order_status: PaymentOrderStatus.id_for(:partially_completed))
# elsif ( payment_statuses.include?(PaymentStatus.id_for(:failed) && payment_statuses.length == 1)
#   payment_order.update(payment_order_status: PaymentOrderStatus.id_for(:failed))
# end



  def pre_validate
    if params.blank? || params[:payment_id].blank? || user.blank?
      add_message :error, "Invalid parameters, please try again"
      return
    end
  end

  def init
    payment_id = params[:id] || params[:payment_id]
    company_id = params[:company_id]
    self.payment = Payment.find_by(id: payment_id, company_id: company_id )
  end

  def validation
    if payment.blank?
        add_message :error, "Cannot find the Payment"
      return
    end
  end

  def process
    payment.update(payment_status_id: PaymentStatus.id_for(:failed), urt: nil)
    payment_order = payment.payment_order
    payment_status_ids = payment_order.payments.pluck(payment_status_id).uniq

    if payment_order_status_ids.include?(PaymentStatus.id_for(:failed)) && payment_order_status_ids.include?(PaymentStatus.id_for(:completed))
      payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:partially_completed) )
    else
      payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:failed))
    end

    parent = payment.parent
    if parent.present? && payment.parent_type == 'Invoice'
      parent.(invoice_status_id: InwardInvoiceStatus.id_for(:unpaid), payable: true )
    end
  end

  def post_process
    add_message :success, "Status Updated"
  end

  def success
    Admin::Payments::Base::PaymentPresenter.new(user, {payment: payment }, messages)
  end
end






